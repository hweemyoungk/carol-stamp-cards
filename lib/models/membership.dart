import 'package:carol/models/user.dart';
import 'package:flutter/material.dart';

class Membership {
  final int priority;
  final String requiredRole;
  final bool isPublishing;
  final bool isActive;
  final String displayName;
  final List<String> descriptions;
  final IconData iconData;
  final ColorScheme colorScheme;
  final String? monthlyPrice;

  Membership({
    required this.priority,
    required this.requiredRole,
    required this.isPublishing,
    required this.isActive,
    required this.displayName,
    required this.descriptions,
    required this.iconData,
    required this.colorScheme,
    required this.monthlyPrice,
  });
  Membership copyWith({
    int? priority,
    String? requiredRole,
    bool? isPublishing,
    bool? isActive,
    String? displayName,
    List<String>? descriptions,
    IconData? iconData,
    ColorScheme? colorScheme,
    String? monthlyPrice,
  }) =>
      Membership(
        priority: priority ?? this.priority,
        requiredRole: requiredRole ?? this.requiredRole,
        isPublishing: isPublishing ?? this.isPublishing,
        isActive: isActive ?? this.isActive,
        displayName: displayName ?? this.displayName,
        descriptions: descriptions ?? this.descriptions,
        iconData: iconData ?? this.iconData,
        colorScheme: colorScheme ?? this.colorScheme,
        monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      );

  Membership checkUserRole(User user) {
    final roles =
        user.accessToken.payload['realm_access']['roles'] as List<dynamic>;
    if (roles.contains(requiredRole)) {
      return copyWith(
        isActive: true,
      );
    }
    return this;
  }

  Color get bgColor => !isPublishing
      ? colorScheme.background.withOpacity(0.5)
      : isActive
          ? colorScheme.primary
          : colorScheme.primaryContainer;

  Color get onBgColor => !isPublishing
      ? colorScheme.onBackground.withOpacity(0.5)
      : isActive
          ? colorScheme.onPrimary
          : colorScheme.onPrimaryContainer;

  static Membership getHighestMembership(Iterable<Membership> candidates) {
    return candidates.reduce((value, element) =>
        value.priority > element.priority ? value : element);
  }
}
