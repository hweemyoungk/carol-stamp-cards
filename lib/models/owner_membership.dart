import 'package:carol/models/membership.dart';

class OwnerMembership extends Membership {
  // @Min(-1)
  final int numMaxAccumulatedTotalStores;
  // @Min(-1)
  final int numMaxCurrentTotalStores;
  // @Min(-1)
  final int numMaxCurrentActiveStores;
  // @Min(-1)
  final int numMaxCurrentTotalBlueprintsPerStore;
  // @Min(-1)
  final int numMaxCurrentActiveBlueprintsPerStore;
  // @Min(-1)
  final int numMaxCurrentTotalRedeemRulesPerBlueprint;
  // @Min(-1)
  final int numMaxCurrentActiveRedeemRulesPerBlueprint;

  OwnerMembership({
    required super.priority,
    required super.requiredRole,
    required super.isPublishing,
    required super.isActive,
    required super.displayName,
    required super.descriptions,
    required super.iconData,
    required super.colorScheme,
    required super.monthlyPrice,
    required this.numMaxAccumulatedTotalStores,
    required this.numMaxCurrentTotalStores,
    required this.numMaxCurrentActiveStores,
    required this.numMaxCurrentTotalBlueprintsPerStore,
    required this.numMaxCurrentActiveBlueprintsPerStore,
    required this.numMaxCurrentTotalRedeemRulesPerBlueprint,
    required this.numMaxCurrentActiveRedeemRulesPerBlueprint,
  });
}
