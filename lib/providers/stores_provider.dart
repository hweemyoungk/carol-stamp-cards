import 'package:carol/models/store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoresNotifier extends StateNotifier<List<Store>> {
  StoresNotifier() : super([]);

  void set(List<Store> stores) {
    state = stores;
  }

  void append(Store store) {
    state = [...state, store];
  }

  void prepend(Store store) {
    state = [store, ...state];
  }

  void appendAll(Iterable<Store> stores) {
    state = [...state, ...stores];
  }

  void prependAll(Iterable<Store> stores) {
    state = [...stores, ...state];
  }
}

final ownerStoresProvider = StateNotifierProvider<StoresNotifier, List<Store>>(
    (ref) => StoresNotifier());
final customerStoresProvider =
    StateNotifierProvider<StoresNotifier, List<Store>>(
        (ref) => StoresNotifier());

class StoresInitLoadedNotifier extends StateNotifier<bool> {
  StoresInitLoadedNotifier() : super(false);

  void set(bool initLoaded) {
    state = initLoaded;
  }
}

final ownerStoresInitLoadedProvider =
    StateNotifierProvider<StoresInitLoadedNotifier, bool>(
        (ref) => StoresInitLoadedNotifier());
final customerStoresInitLoadedProvider =
    StateNotifierProvider<StoresInitLoadedNotifier, bool>(
        (ref) => StoresInitLoadedNotifier());
