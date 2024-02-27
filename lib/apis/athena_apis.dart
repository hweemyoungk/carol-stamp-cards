import 'dart:convert';
import 'dart:developer' as developer;

import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/params/athena.dart' as athena_params;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pkce/pkce.dart';

Future<Map<String, dynamic>?> tryRefreshOidc(
  Map<String, dynamic> oidc, {
  int expMarginSeconds = 0,
}) async {
  // Refresh
  final refreshToken = oidc['refresh_token'] as String;
  final currentTimestampSeconds = getCurrentTimestampSeconds();
  final errorMsg = validateRefreshToken(
    oidc,
    secondsSinceEpoch: currentTimestampSeconds,
  );
  if (errorMsg != null) {
    Carol.showTextSnackBar(
      text: errorMsg,
      level: SnackBarLevel.debug,
    );
    return null;
  }
  final res = await httpPost(
    getTokenEndpoint(),
    headers: null,
    body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': athena_params.clientId,
    },
    withAuthHeaders: false,
  );
  developer.log('[+]oidc: ${res.body}');
  final newOidc = json.decode(res.body);

  // Validate
  final invalidOidcMsgs = validateOidc(newOidc);
  if (invalidOidcMsgs != null) {
    Carol.showTextSnackBar(
      text:
          'Received invalid OIDC token${invalidOidcMsgs.fold('\n- ', (prev, cur) => '$prev\n- $cur')}',
      level: SnackBarLevel.debug,
    );
    return null;
  }

  return newOidc;
}

String genState({int length = 30}) => genAlphanumeric(length);

// Uri getTokenEndpoint() => Uri.http(
Uri getTokenEndpoint() => Uri.https(
      athena_params.keycloakHostname,
      athena_params.tokenPath,
    );

Uri getAuthEndpoint({
  required String state,
  required PkcePair pkcePair,
}) {
  return Uri.https(
    athena_params.keycloakHostname,
    athena_params.authPath,
    {
      'client_id': athena_params.clientId,
      'response_type': 'code',
      'scope': 'openid offline_access',
      'redirect_uri': athena_params.redirectUri,
      'state': state,
      'code_challenge': pkcePair.codeChallenge,
      'code_challenge_method': 'S256'
    },
  );
}

List<String>? validateOidc(Map<String, dynamic> oidc) {
  final secondsSinceEpoch = getCurrentTimestampSeconds();

  // not-before-policy
  final String? revokedTokenMsg = validateNotBeforePolicy(
    oidc,
    secondsSinceEpoch: secondsSinceEpoch,
  );

  // access_token
  final accessTokenMsg = validateAccessToken(
    oidc,
    secondsSinceEpoch: secondsSinceEpoch,
  );

  // id_token
  final idTokenMsg = validateIdToken(
    oidc,
    secondsSinceEpoch: secondsSinceEpoch,
  );

  // refresh_token
  final refreshTokenMsg = validateRefreshToken(
    oidc,
    secondsSinceEpoch: secondsSinceEpoch,
  );

  final msgs = [revokedTokenMsg, accessTokenMsg, idTokenMsg, refreshTokenMsg]
      .where((msg) => msg != null)
      .cast<String>()
      .toList();

  if (msgs.isEmpty) {
    return null;
  }

  return msgs;
}

String? validateNotBeforePolicy(
  Map<String, dynamic> oidc, {
  required int secondsSinceEpoch,
}) {
  final notBeforePolicy = oidc['not-before-policy'];
  if (notBeforePolicy != null &&
      notBeforePolicy is int &&
      notBeforePolicy != 0 &&
      notBeforePolicy < secondsSinceEpoch) {
    // Already passed not-before-policy
    return 'Revoked token';
  }
  return null;
}

String? validateAccessToken(
  Map<String, dynamic> oidc, {
  required int secondsSinceEpoch,
}) {
  if (oidc['access_token'] == null) {
    return 'Access token not found';
  }
  try {
    final accessToken = JWT.decode(oidc['access_token']);
    final accessTokenPayload = accessToken.payload;
    if (accessTokenPayload['exp'] < secondsSinceEpoch) {
      return 'Access token expired';
    }
    return _validateEmailVerified(accessToken);
  } catch (e) {
    return 'ERROR during parsing access token';
  }
}

String? validateIdToken(
  Map<String, dynamic> oidc, {
  required int secondsSinceEpoch,
}) {
  if (oidc['id_token'] == null) {
    return 'ID token not found';
  }
  try {
    final idToken = JWT.decode(oidc['id_token']);
    final idTokenPayload = idToken.payload;
    if (idTokenPayload['exp'] < secondsSinceEpoch) {
      return 'ID token expired';
    }
    return _validateEmailVerified(idToken);
  } catch (e) {
    return 'ERROR during parsing ID token';
  }
}

String? validateRefreshToken(
  Map<String, dynamic> oidc, {
  required int secondsSinceEpoch,
}) {
  if (oidc['refresh_token'] == null) {
    return 'Refresh token not found';
  }
  try {
    // final String refreshToken = oidc['refresh_token'];
    // final refreshTokenPayload = json.decode(String.fromCharCodes(
    //     base64.decode(base64.normalize(refreshToken.split('.')[1]))));
    final refreshToken = JWT.decode(oidc['refresh_token']);
    final exp = refreshToken.payload['exp'];
    if (exp != null && exp < secondsSinceEpoch) {
      return 'Refresh token expired';
    }
  } catch (e) {
    return 'ERROR during parsing refresh token';
  }
  return null;
}

String? _validateEmailVerified(JWT jwt) {
  final emailVerified = jwt.payload['email_verified'] as bool?;
  if (emailVerified == null || !emailVerified) {
    return 'Email not verified';
  }
  return null;
}
