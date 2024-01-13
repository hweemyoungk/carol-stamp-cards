import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerScreenReloadingNotifier extends StateNotifier<bool> {
  CustomerScreenReloadingNotifier() : super(false);

  void set(bool isReloading) {
    state = isReloading;
  }
}

final customerScreenReloadingProvider =
    StateNotifierProvider<CustomerScreenReloadingNotifier, bool>(
        (ref) => CustomerScreenReloadingNotifier());
