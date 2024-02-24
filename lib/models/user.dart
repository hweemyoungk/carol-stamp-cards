import 'package:carol/main.dart';
import 'package:carol/models/customer_membership.dart';
import 'package:carol/models/membership.dart';
import 'package:carol/models/owner_membership.dart';
import 'package:carol/screens/membership_screen.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class User {
  final String id;
  final String displayName;
  final String? profileImageUrl;
  final JWT idToken;
  final JWT accessToken;
  final JWT refreshToken;
  final CustomerMembership? customerMembership;
  final OwnerMembership? ownerMembership;

  User._({
    required this.id,
    required this.displayName,
    required this.profileImageUrl,
    required this.idToken,
    required this.accessToken,
    required this.refreshToken,
    required this.customerMembership,
    required this.ownerMembership,
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
      customerMembership: _getHighestCustomerMembership(accessToken),
      ownerMembership: _getHighestOwnerMembership(accessToken),
    );
  }
}

CustomerMembership? _getHighestCustomerMembership(JWT accessToken) {
  final roles = _getRoles(accessToken);
  final candidates = roles
      .where((element) => element.startsWith('customer-'))
      .map((role) => customerMemberships[role])
      .where((element) => element != null)
      .cast<CustomerMembership>();
  if (candidates.isEmpty) {
    return null;
  }
  return Membership.getHighestMembership(candidates.cast<Membership>())
      as CustomerMembership;
}

OwnerMembership? _getHighestOwnerMembership(JWT accessToken) {
  final roles = _getRoles(accessToken);
  final candidates = roles
      .where((element) => element.startsWith('owner-'))
      .map((role) => ownerMemberships[role])
      .where((element) => element != null)
      .cast<OwnerMembership>();
  if (candidates.isEmpty) {
    return null;
  }
  return Membership.getHighestMembership(candidates.cast<Membership>())
      as OwnerMembership;
}

List<String> _getRoles(JWT accessToken) =>
    (accessToken.payload['realm_access']['roles'] as List<dynamic>)
        .cast<String>();

String? _getDisplayName(JWT accessToken) {
  return accessToken.payload['name'] ??
      accessToken.payload['preferred_username'] ??
      accessToken.payload['email'];
}
