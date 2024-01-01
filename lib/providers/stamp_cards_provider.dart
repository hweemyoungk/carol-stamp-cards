import 'package:carol/models/stamp_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StampCardsNotifier extends StateNotifier<List<StampCard>> {
  StampCardsNotifier() : super([]);

  void set(List<StampCard> stampCards, [bool sort = true]) {
    state = stampCards;
    if (sort) {
      this.sort();
    }
  }

  void append(StampCard stampCard, [bool sort = true]) {
    state = [...state, stampCard];
    if (sort) {
      this.sort();
    }
  }

  void prepend(StampCard stampCard, [bool sort = true]) {
    state = [stampCard, ...state];
    if (sort) {
      this.sort();
    }
  }

  void appendAll(Iterable<StampCard> stampCards, [bool sort = true]) {
    state = [...state, ...stampCards];
    if (sort) {
      this.sort();
    }
  }

  void prependAll(Iterable<StampCard> stampCards, [bool sort = true]) {
    state = [...stampCards, ...state];
    if (sort) {
      this.sort();
    }
  }

  void sort() {
    state.sort(
      (card1, card2) =>
          card2.lastModifiedDate.compareTo(card1.lastModifiedDate),
    );
    state = [...state];
  }
}

final stampCardsProvider =
    StateNotifierProvider<StampCardsNotifier, List<StampCard>>(
        (ref) => StampCardsNotifier());

class StampCardsInitLoadedNotifier extends StateNotifier<bool> {
  StampCardsInitLoadedNotifier() : super(false);

  void set(bool initLoaded) {
    state = initLoaded;
  }
}

final stampCardsInitLoadedProvider =
    StateNotifierProvider<StampCardsInitLoadedNotifier, bool>(
        (ref) => StampCardsInitLoadedNotifier());
