import 'package:carol/models/membership.dart';

class CustomerMembership extends Membership {
  // @Min(-1)
  final int numMaxAccumulatedTotalCards;
  // @Min(-1)
  final int numMaxCurrentTotalCards;
  // @Min(-1)
  final int numMaxCurrentActiveCards;

  CustomerMembership({
    required super.priority,
    required super.requiredRole,
    required super.isPublishing,
    required super.isActive,
    required super.displayName,
    required super.descriptions,
    required super.iconData,
    required super.colorScheme,
    required super.monthlyPrice,
    required this.numMaxAccumulatedTotalCards,
    required this.numMaxCurrentTotalCards,
    required this.numMaxCurrentActiveCards,
  });
}
