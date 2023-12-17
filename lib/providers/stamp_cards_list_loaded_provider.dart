import 'package:flutter_riverpod/flutter_riverpod.dart';

class StampCardsListLoadedNotifier extends StateNotifier<bool> {
  StampCardsListLoadedNotifier() : super(false);

  void set({
    required bool loaded,
  }) {
    state = loaded;
  }
}

final stampCardsListLoadedProvider =
    StateNotifierProvider<StampCardsListLoadedNotifier, bool>(
        (ref) => StampCardsListLoadedNotifier());
