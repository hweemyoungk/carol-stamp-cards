import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreNotifier extends StateNotifier<Store> {
  StoreNotifier({required this.store}) : super(store);

  final Store store;

  void set({
    required Store store,
  }) {
    state = store;
  }
}

class StoreProviders {
// Store.id => StoreNotifier
  static final Map<String, StateNotifierProvider<StoreNotifier, Store>>
      providers = {};

  static bool tryAddProvider({required Store store}) {
    final provider = providers[store.id];
    if (provider != null) return false;
    providers[store.id] = StateNotifierProvider<StoreNotifier, Store>(
        (ref) => StoreNotifier(store: store));
    return true;
  }
}
