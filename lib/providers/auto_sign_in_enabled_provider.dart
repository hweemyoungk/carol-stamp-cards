import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoSignInEnabledNotifier extends StateNotifier<bool> {
  AutoSignInEnabledNotifier() : super(false);

  void set(bool isEnabled) {
    state = isEnabled;
  }
}

final autoSignInEnabledProvider =
    StateNotifierProvider<AutoSignInEnabledNotifier, bool>(
        (ref) => AutoSignInEnabledNotifier());
