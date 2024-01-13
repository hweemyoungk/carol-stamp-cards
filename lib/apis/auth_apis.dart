import 'dart:convert';

import 'package:carol/utils.dart';

const alphanumericChars =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

String genAlphanumeric(int length) => String.fromCharCodes(Iterable.generate(
    length,
    (_) => alphanumericChars
        .codeUnitAt(random.nextInt(alphanumericChars.length))));

String genState({int length = 30}) => genAlphanumeric(length);

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
    final String accessToken = oidc['access_token'];
    // final base64 = Base64Codec();
    final accessTokenPayload = json.decode(String.fromCharCodes(
        base64.decode(base64.normalize(accessToken.split('.')[1]))));
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
    final String idToken = oidc['id_token'];
    final idTokenPayload = json.decode(String.fromCharCodes(
        base64.decode(base64.normalize(idToken.split('.')[1]))));
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
    final String refreshToken = oidc['refresh_token'];
    final refreshTokenPayload = json.decode(String.fromCharCodes(
        base64.decode(base64.normalize(refreshToken.split('.')[1]))));
    if (refreshTokenPayload['exp'] < secondsSinceEpoch) {
      return 'Refresh token expired';
    }
  } catch (e) {
    return 'ERROR during parsing refresh token';
  }
  return null;
}
