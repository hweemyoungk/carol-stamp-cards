import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStatusNotifier extends StateNotifier<AuthStatus> {
  AuthStatusNotifier() : super(AuthStatus.unauthenticated);

  void set(AuthStatus authStatus) {
    state = authStatus;
  }
}

final authStatusProvider =
    StateNotifierProvider<AuthStatusNotifier, AuthStatus>(
        (ref) => AuthStatusNotifier());

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}
