import 'package:carol/models/stamp_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StampCardNotifier extends StateNotifier<StampCard> {
  StampCardNotifier({required this.stampCard}) : super(stampCard);

  final StampCard stampCard;

  void set({
    required StampCard stampCard,
  }) {
    state = stampCard;
  }
}

class StampCardProviders {
// StampCard.id => StampCardNotifier
  static final Map<String, StateNotifierProvider<StampCardNotifier, StampCard>>
      providers = {};

  static bool tryAddProvider({required StampCard stampCard}) {
    final provider = providers[stampCard.id];
    if (provider != null) return false;
    providers[stampCard.id] =
        StateNotifierProvider<StampCardNotifier, StampCard>(
            (ref) => StampCardNotifier(stampCard: stampCard));
    return true;
  }
}
