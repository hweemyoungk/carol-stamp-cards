import 'package:flutter_riverpod/flutter_riverpod.dart';

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
