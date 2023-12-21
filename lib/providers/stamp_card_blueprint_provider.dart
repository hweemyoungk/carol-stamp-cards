import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StampCardBlueprintNotifier extends StateNotifier<StampCardBlueprint> {
  StampCardBlueprintNotifier({required this.blueprint}) : super(blueprint);

  final StampCardBlueprint blueprint;

  void set({
    required StampCardBlueprint blueprint,
  }) {
    state = blueprint;
  }
}

class StampCardBlueprintProviders {
// StampCardBlueprint.id => StampCardNotifier
  static final Map<String,
          StateNotifierProvider<StampCardBlueprintNotifier, StampCardBlueprint>>
      providers = {};

  static bool tryAddProvider({required StampCardBlueprint stampCardBlueprint}) {
    final provider = providers[stampCardBlueprint.id];
    if (provider != null) return false;
    providers[stampCardBlueprint.id] =
        StateNotifierProvider<StampCardBlueprintNotifier, StampCardBlueprint>(
            (ref) => StampCardBlueprintNotifier(blueprint: stampCardBlueprint));
    return true;
  }
}
