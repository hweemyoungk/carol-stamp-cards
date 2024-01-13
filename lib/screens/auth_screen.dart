import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:carol/apis/auth_apis.dart';
import 'package:carol/apis/customer_apis_dummy.dart' as customerApisDummy;
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/user.dart';
import 'package:carol/params.dart';
import 'package:carol/providers/auth_status_provider.dart';
import 'package:carol/providers/auto_sign_in_enabled_provider.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pkce/pkce.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isAutoSigningIn = true;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    tryAutoSignIn();
  }

  Future<void> tryAutoSignIn() async {
    // 1. Get stored credential
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userCredential = prefs.getString('userCredential');

    // 2. Validate credential
    if (userCredential == null) {
      if (mounted) {
        setState(() {
          _isAutoSigningIn = false;
        });
      }
      return;
    }

    final oidc = json.decode(userCredential);
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
    final refreshToken = oidc['refresh_token'] as String;
    try {
      final res = await httpPost(
        tokenEndpoint,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
        },
      );

      final oidc = json.decode(res.body);

      // Verify OIDC token
      final invalidOidcMsgs = validateOidc(oidc);
      if (invalidOidcMsgs != null) {
        // Invalid OIDC token
        prefs.remove('userCredential');
        Carol.showTextSnackBar(
          text:
              'Failed to auto sign in. Please sign in manually.${invalidOidcMsgs.fold('\n- ', (prev, cur) => '$prev\n- $cur')}',
          level: SnackBarLevel.error,
        );
        // Pop all
        if (mounted) {
          Navigator.of(context).popUntil(ModalRoute.withName('/auth'));
        }
        return;
      }

      // Store credential
      // TEST: stale refresh token
      // final staleOidc = getStaleRefreshOidc(oidc);
      // prefs.setString('userCredential', json.encode(staleOidc));

      prefs.setString('userCredential', res.body);

      // TODO: Implement
      // 4. Get User and store

      // 5. Navigate to DashboardScreen
      setState(() {
        _isAutoSigningIn = false;
      });
    } on Exception catch (e) {
      Carol.showTextSnackBar(
        text: e.toString(),
        seconds: 10,
        level: SnackBarLevel.error,
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authStatusProvider);
    final isAutoSignInEnabled = ref.watch(autoSignInEnabledProvider);
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
          value: isAutoSignInEnabled,
          onChanged: _isAutoSigningIn || authStatus == AuthStatus.authenticating
              ? null
              : (value) {
                  setState(() {
                    ref.read(autoSignInEnabledProvider.notifier).set(value);
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
        onPressed: null,
        style: authButtonStyle,
        child: CircularProgressIndicatorInButton(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      );
    } else {
      // authStatus == AuthStatus.authenticated
      authButton = ElevatedButton(
        onPressed: null,
        style: authButtonStyle,
        child: Text(
          'You are signed in, ${currentUser.displayName}!',
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
    final state = genState();
    // Locally store state
    originalState = state;

    // This is a stupid idea...
    // Send state to cache
    // final urlSendStateToCache = Uri.http(aliciaAuthHostname, '/state');
    // final res = await httpPost(
    //   urlSendStateToCache,
    //   headers: {
    //     "Content-Type": "application/json;charset=utf-8",
    //   },
    //   body: json.encode({
    //     "state": originalState,
    //   }),
    // );

    // Generate code challenge and code verifier
    final pkcePair = PkcePair.generate();
    originalPkcePair = pkcePair;

    // Authenticate
    final url = Uri.http(
      keycloakHostname,
      '/realms/$realmName/protocol/openid-connect/auth',
      {
        'client_id': clientId,
        'response_type': 'code',
        'scope': 'openid',
        'redirect_uri': redirectUri,
        'state': state,
        'code_challenge': pkcePair.codeChallenge,
        'code_challenge_method': 'S256'
      },
    );
    await launchInBrowserView(url);

    // Dummy
    // Set User
    currentUser = await DesignUtils.delaySeconds(1).then(
      (value) => User(
        id: uuid.v4(),
        displayName: 'HMK',
        profileImageUrl: 'assets/images/schnitzel-3279045_1280.jpg',
      ),
    );

    // Load Init Entities: Landing page is CustomerScreen, so load Customer Cards and Stores
    // TODO: disable dummy
    /* final stampCardsInitLoadedNotifier =
        ref.read(stampCardsInitLoadedProvider.notifier);
    final stampCardsNotifier = ref.read(stampCardsProvider.notifier);
    final customerStoresInitLoadedNotifier =
        ref.read(customerStoresInitLoadedProvider.notifier);
    final customerStoresNotifier = ref.read(customerStoresProvider.notifier);
    customerApis.initLoadCustomerEntities(
      customerStoresInitLoadedNotifier: customerStoresInitLoadedNotifier,
      customerStoresNotifier: customerStoresNotifier,
      stampCardsInitLoadedNotifier: stampCardsInitLoadedNotifier,
      stampCardsNotifier: stampCardsNotifier,
    ); */
    await customerApisDummy.initLoadCustomerEntities(ref);

    // Next Screen
    // if (mounted) {
    //   Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => const DashboardScreen(),
    //   ));
    // }
  }
}
