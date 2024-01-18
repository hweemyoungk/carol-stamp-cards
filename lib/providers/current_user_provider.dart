import 'package:carol/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentUserNotifier extends StateNotifier<User?> {
  CurrentUserNotifier() : super(null);

  void set(User? user) {
    state = user;
  }
}

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>(
    (ref) => CurrentUserNotifier());
