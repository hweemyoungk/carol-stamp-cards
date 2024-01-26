import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedeemRequestsInitLoadedNotifier extends StateNotifier<bool> {
  RedeemRequestsInitLoadedNotifier() : super(false);

  void set(bool initLoaded) {
    state = initLoaded;
  }
}

final ownerRedeemRequestsInitLoadedProvider =
    StateNotifierProvider<RedeemRequestsInitLoadedNotifier, bool>(
        (ref) => RedeemRequestsInitLoadedNotifier());
