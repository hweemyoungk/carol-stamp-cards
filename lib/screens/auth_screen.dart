import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:app_links/app_links.dart';
import 'package:carol/apis/auth_apis.dart';
import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/user.dart';
import 'package:carol/params/auth.dart' as auth_params;
import 'package:carol/params/shared_preferences.dart'
    as shared_preferences_params;
import 'package:carol/providers/auth_status_notifier.dart';
import 'package:carol/providers/current_user_notifier.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkce/pkce.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>(
    (ref) => CurrentUserNotifier());
final authStatusProvider =
    StateNotifierProvider<AuthStatusNotifier, AuthStatus>(
        (ref) => AuthStatusNotifier());

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isAutoSigningIn = true;
  bool _isAutoSignInEnabled = false;
  late AppLinks _appLinks;
  String? _stateToken;
  PkcePair? _pkcePair;

  @override
  void initState() {
    super.initState();
    _bindAuthCallback();
    _tryAutoSignIn(ignore: false);
  }

  Future<void> _tryAutoSignIn({bool ignore = false}) async {
    if (ignore) {
      if (mounted) {
        setState(() {
          _isAutoSigningIn = false;
        });
      }
      return;
    }
    final authStatusNotifier = ref.read(authStatusProvider.notifier);
    final currentUserNotifier = ref.read(currentUserProvider.notifier);

    // 1. Get stored credential
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final oidcString = prefs.getString(shared_preferences_params.oidcKey);

    // 2. Validate credential
    if (oidcString == null) {
      if (mounted) {
        setState(() {
          _isAutoSigningIn = false;
        });
      }
      return;
    }

    final oidc = json.decode(oidcString);
    final secondsSinceEpoch = getCurrentTimestampSeconds();

    final refreshTokenMsg = validateRefreshToken(
      oidc,
      secondsSinceEpoch: secondsSinceEpoch,
    );
    if (refreshTokenMsg != null) {
      Carol.showTextSnackBar(
        text: 'Sign in again: $refreshTokenMsg',
        level: SnackBarLevel.warn,
      );
      if (mounted) {
        setState(() {
          _isAutoSigningIn = false;
        });
      }
      return;
    }

    // 3. Refresh to latest credential
    final Map<String, dynamic>? newOidc;
    try {
      newOidc = await tryRefreshOidc(oidc);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to auto-sign-in.',
      );
      authStatusNotifier.set(AuthStatus.unauthenticated);
      if (mounted) {
        setState(() {
          _isAutoSigningIn = false;
        });
      }
      return;
    }

    if (newOidc == null) {
      // Got invalid OIDC
      prefs.remove(shared_preferences_params.oidcKey);
      Carol.showTextSnackBar(
        text: 'Failed to auto sign in. Please sign in manually.',
        level: SnackBarLevel.error,
      );
      // Pop all
      if (mounted) {
        Navigator.of(context).popUntil(ModalRoute.withName('/auth'));
      }
      return;
    }

    // Replace
    currentOidc = newOidc;

    // Set timer
    setRefreshOidcToggleTimer(oidc: newOidc);

    // Store credential
    // TEST: stale refresh token
    // final staleOidc = getStaleRefreshOidc(oidc);
    // prefs.setString(shared_preferences_params.oidcKey, json.encode(staleOidc));
    prefs.setString(shared_preferences_params.oidcKey, json.encode(newOidc));

    // 5. Navigate to DashboardScreen
    setState(() {
      _isAutoSigningIn = false;
    });

    // Set User
    final currentUser = User(
      oidc: newOidc,
      profileImageUrl: 'assets/images/schnitzel-3279045_1280.jpg',
    );
    currentUserNotifier.set(currentUser);
    developer.log('[+]access token: ${newOidc['access_token']}');

    // Load Init Entities: Landing page is CustomerScreen, so load Customer Cards and Stores
    if (!mounted) return;
    _loadInitialModels();

    // Next Screen
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      '/dashboard',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authStatusProvider);
    // final isAutoSignInEnabled = ref.watch(autoSignInEnabledProvider);
    final currentUser = ref.watch(currentUserProvider);
    final autoSignInSection = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: DesignUtils.basicWidgetEdgeInsets(),
          child: Text(
            'Remember me',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        // const SizedBox(width: 10),
        Switch(
          value: _isAutoSignInEnabled,
          onChanged: _isAutoSigningIn || authStatus == AuthStatus.authenticating
              ? null
              : (value) {
                  setState(() {
                    _isAutoSignInEnabled = value;
                  });
                },
        ),
      ],
    );
    final ElevatedButton authButton;
    final authButtonStyle = ElevatedButton.styleFrom(
      disabledBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
    if (_isAutoSigningIn) {
      authButton = ElevatedButton(
        onPressed: null,
        child: Text(
          'Please wait...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    } else if (authStatus == AuthStatus.unauthenticated) {
      authButton = ElevatedButton(
        onPressed: _onPressSignIn,
        style: authButtonStyle,
        child: Text(
          'Sign In / Up',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    } else if (authStatus == AuthStatus.authenticating) {
      authButton = ElevatedButton(
        onPressed: _onPressCancelAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
        child: Text(
          'Abort Sign In / Up',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      );
    } else {
      // authStatus == AuthStatus.authenticated
      authButton = ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/dashboard',
          );
        },
        style: authButtonStyle,
        child: Text(
          'You are signed in, ${currentUser!.displayName}!',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: const Icon(
                  Icons.card_giftcard,
                  size: 150,
                ),
              ),
              _isAutoSigningIn
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : Card(
                      margin: const EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(2),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: DesignUtils.basicWidgetEdgeInsets(),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Welcome to',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                      ),
                                      Text(
                                        'Carol Cards',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: DesignUtils.basicWidgetEdgeInsets(),
                                  child: Column(
                                    children: [
                                      authButton,
                                      autoSignInSection,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPressSignIn() async {
    final authStatusNotifier = ref.read(authStatusProvider.notifier);
    authStatusNotifier.set(AuthStatus.authenticating);

    // Generate state
    _stateToken = genState();

    // Generate code challenge and code verifier
    _pkcePair = PkcePair.generate();

    // Authenticate
    final url = getAuthEndpoint(state: _stateToken!, pkcePair: _pkcePair!);
    await launchInBrowserView(url);
  }

  void _bindAuthCallback() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {
      if (uri.path == '/auth/callback') {
        _handleAuthCallback(uri);
      }
    });
  }

  Future<void> _handleAuthCallback(Uri uri) async {
    final authStatusNotifier = ref.read(authStatusProvider.notifier);
    // final isAutoSignInEnabled = ref.read(autoSignInEnabledProvider);
    final currentUserNotifier = ref.read(currentUserProvider.notifier);

    if (_pkcePair == null) {
      Carol.showTextSnackBar(
        text: 'Lost PKCE data',
        level: SnackBarLevel.error,
      );
      authStatusNotifier.set(AuthStatus.unauthenticated);
      // Pop all
      Navigator.of(context).popUntil(ModalRoute.withName('/auth'));
      return;
    }

    // Verify state
    final state = uri.queryParameters['state'];
    if (state != _stateToken) {
      Carol.showTextSnackBar(
        text: 'Invalid state token',
        level: SnackBarLevel.error,
      );
      authStatusNotifier.set(AuthStatus.unauthenticated);
      // Pop all
      Navigator.of(context).popUntil(ModalRoute.withName('/auth'));
      return;
    }

    // Exchange code
    final code = uri.queryParameters['code'];
    final Map<String, dynamic> oidc;
    try {
      final res = await httpPost(
        getTokenEndpoint(),
        headers: null,
        body: {
          'grant_type': 'authorization_code',
          'client_id': auth_params.clientId,
          'code': code,
          'code_verifier': _pkcePair!.codeVerifier,
          'redirect_uri': auth_params.redirectUri,
        },
        withAuthHeaders: false,
      );
      oidc = json.decode(res.body);

      // Verify OIDC token
      final invalidOidcMsgs = validateOidc(oidc);
      if (invalidOidcMsgs != null) {
        // Invalid OIDC token
        authStatusNotifier.set(AuthStatus.unauthenticated);
        Carol.showTextSnackBar(
          text:
              'Failed to authenticate. Please contact admin.${invalidOidcMsgs.fold('\n- ', (prev, cur) => '$prev\n- $cur')}',
          level: SnackBarLevel.error,
        );
        // Pop all
        if (mounted) {
          Navigator.of(context).popUntil(ModalRoute.withName('/auth'));
        }
        return;
      }

      // Store credential if auto sign in is enabled
      final prefs = await SharedPreferences.getInstance();
      if (_isAutoSignInEnabled) {
        prefs.setString(shared_preferences_params.oidcKey, res.body);
      } else {
        // Try removing credential if auto sign in is disabled
        prefs.remove(shared_preferences_params.oidcKey);
      }

      authStatusNotifier.set(AuthStatus.authenticated);
    } on Exception catch (e) {
      authStatusNotifier.set(AuthStatus.unauthenticated);
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to sign in.',
      );
      return;
    }

    developer.log('[+]access token: ${oidc['access_token']}');

    currentOidc = oidc;

    // Set User
    final currentUser = User(
      oidc: oidc,
      profileImageUrl: 'assets/images/schnitzel-3279045_1280.jpg',
    );
    currentUserNotifier.set(currentUser);

    // Load Init Entities: Landing page is CustomerScreen, so load Customer Cards and Stores
    if (!mounted) return;
    _loadInitialModels();

    // Next Screen
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      '/dashboard',
    );
  }

  void _onPressCancelAuth() {
    ref.read(authStatusProvider.notifier).set(AuthStatus.unauthenticated);
    ref.read(currentUserProvider.notifier).set(null);
  }

  Future<void> _loadInitialModels() async {
    // Load Init Entities: Landing page is CustomerScreen, so load Customer Cards and Stores
    try {
      await customer_apis.reloadCustomerModels(ref);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to load customer entities.',
      );
    }
  }
}
