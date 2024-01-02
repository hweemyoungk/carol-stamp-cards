import 'package:flutter_riverpod/flutter_riverpod.dart';

class StampCardsInitLoadedNotifier extends StateNotifier<bool> {
  StampCardsInitLoadedNotifier() : super(false);

  void set(bool initLoaded) {
    state = initLoaded;
  }
}

final stampCardsInitLoadedProvider =
    StateNotifierProvider<StampCardsInitLoadedNotifier, bool>(
        (ref) => StampCardsInitLoadedNotifier());
