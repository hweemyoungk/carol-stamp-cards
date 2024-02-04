import 'package:flutter_riverpod/flutter_riverpod.dart';

class BooleanNotifier extends StateNotifier<bool> {
  BooleanNotifier(bool state) : super(state);

  void set(bool value) {
    state = value;
  }
}
