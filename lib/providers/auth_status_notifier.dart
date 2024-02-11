import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStatusNotifier extends StateNotifier<AuthStatus> {
  // AuthStatusNotifier() : super(AuthStatus.unauthenticated);
  AuthStatusNotifier() : super(AuthStatus.authenticating); // Try auto sign in

  void set(AuthStatus authStatus) {
    state = authStatus;
  }
}

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}
