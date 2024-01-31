import 'package:carol/main.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class User {
  final String id;
  final String displayName;
  final String? profileImageUrl;
  final JWT idToken;
  final JWT accessToken;
  final JWT refreshToken;

  User._({
    required this.id,
    required this.displayName,
    required this.profileImageUrl,
    required this.idToken,
    required this.accessToken,
    required this.refreshToken,
  });

  factory User({
    required Map<String, dynamic> oidc,
    required String? profileImageUrl,
  }) {
    final idToken = JWT.decode(oidc['id_token']);
    final accessToken = JWT.decode(oidc['access_token']);
    final refreshToken = JWT.decode(oidc['refresh_token']);
    final displayName = _getDisplayName(accessToken);
    if (displayName == null) {
      Carol.showTextSnackBar(
        text: 'Couldn\'t find proper username',
        level: SnackBarLevel.warn,
      );
    }
    return User._(
      id: accessToken.payload['sub'],
      displayName: displayName ?? 'Temporary Username',
      profileImageUrl: profileImageUrl,
      idToken: idToken,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

String? _getDisplayName(JWT accessToken) {
  return accessToken.payload['name'] ??
      accessToken.payload['preferred_username'] ??
      accessToken.payload['email'];
}
