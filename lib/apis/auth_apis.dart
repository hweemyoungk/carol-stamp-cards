import 'package:carol/params/auth.dart' as auth_params;
import 'package:carol/utils.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pkce/pkce.dart';

const alphanumericChars =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

String genAlphanumeric(int length) => String.fromCharCodes(Iterable.generate(
    length,
    (_) => alphanumericChars
        .codeUnitAt(random.nextInt(alphanumericChars.length))));

String genState({int length = 30}) => genAlphanumeric(length);

Uri getTokenEndpoint() => Uri.http(
      auth_params.keycloakHostname,
      '/realms/${auth_params.realmName}/protocol/openid-connect/token',
    );

Uri getAuthEndpoint({
  required String state,
  required PkcePair pkcePair,
}) =>
    Uri.http(
      auth_params.keycloakHostname,
      '/realms/${auth_params.realmName}/protocol/openid-connect/auth',
      {
        'client_id': auth_params.clientId,
        'response_type': 'code',
        'scope': 'openid',
        'redirect_uri': auth_params.redirectUri,
        'state': state,
        'code_challenge': pkcePair.codeChallenge,
        'code_challenge_method': 'S256'
      },
    );

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

  final msgs = [revokedTokenMsg, accessTokenMsg, idTokenMsg]
      .where((msg) => msg != null)
      .cast<String>()
      .toList();

  if (msgs.isEmpty) {
    return null;
  }

  return msgs;
}

int getCurrentTimestampSeconds() =>
    (DateTime.timestamp().millisecondsSinceEpoch / 1000).ceil();

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
    // final String accessToken = oidc['access_token'];
    // final accessTokenPayload = json.decode(String.fromCharCodes(
    //     base64.decode(base64.normalize(accessToken.split('.')[1]))));
    final accessToken = JWT.decode(oidc['access_token']);
    final accessTokenPayload = accessToken.payload;
    if (accessTokenPayload['exp'] < secondsSinceEpoch) {
      return 'Access token expired';
    }
  } catch (e) {
    return 'ERROR during parsing access token';
  }
  return null;
}

String? validateIdToken(
  Map<String, dynamic> oidc, {
  required int secondsSinceEpoch,
}) {
  if (oidc['id_token'] == null) {
    return 'ID token not found';
  }
  try {
    // final String idToken = oidc['id_token'];
    // final idTokenPayload = json.decode(String.fromCharCodes(
    //     base64.decode(base64.normalize(idToken.split('.')[1]))));
    final idToken = JWT.decode(oidc['id_token']);
    final idTokenPayload = idToken.payload;
    if (idTokenPayload['exp'] < secondsSinceEpoch) {
      return 'ID token expired';
    }
  } catch (e) {
    return 'ERROR during parsing ID token';
  }
  return null;
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
    final refreshTokenPayload = refreshToken.payload;
    if (refreshTokenPayload['exp'] < secondsSinceEpoch) {
      return 'Refresh token expired';
    }
  } catch (e) {
    return 'ERROR during parsing refresh token';
  }
  return null;
}
