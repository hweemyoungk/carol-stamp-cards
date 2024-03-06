import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:carol/apis/app_apis.dart' as app_apis;
import 'package:carol/apis/athena_apis.dart';
import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/app_notice.dart';
import 'package:carol/models/user.dart';
import 'package:carol/params/athena.dart' as auth_params;
import 'package:carol/params/shared_preferences.dart' as prefs_params;
import 'package:carol/providers/auth_status_notifier.dart';
import 'package:carol/providers/current_user_notifier.dart';
import 'package:carol/screens/app_notice_dialog_screen.dart';
import 'package:carol/screens/dashboard_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/language_dropdown_button.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pkce/pkce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>(
    (ref) => CurrentUserNotifier());

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late AppLocalizations _localizations;
  AuthStatus _authStatus = AuthStatus.authenticating;
  bool _waiting = true;
  bool _isAutoSignInEnabled = false;
  late AppLinks _appLinks;
  String? _stateToken;
  PkcePair? _pkcePair;

  @override
  void initState() {
    super.initState();
    _bindAuthCallback();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _localizations = AppLocalizations.of(context)!;
    _initFromDevice().then(
      (proceed) async {
        if (!proceed) {
          return false;
        }
        await _checkRequirements(ignore: false);
        return true;
      },
    ).then(
      (proceed) async {
        if (!proceed) {
          return false;
        }

        try {
          await _showAppNotices();
        } on Exception catch (e) {
          Carol.showExceptionSnackBar(
            e,
            contextMessage: _localizations.failedToLoadAppNotices,
            localizations: _localizations,
          );
        }
        return true;
      },
    ).then(
      (proceed) async {
        if (!proceed) {
          return false;
        }
        await _tryAutoSignIn(ignore: false);
        return true;
      },
    );
  }

  /// Proceed chain with true, stop chain with false.
  Future<bool> _initFromDevice() async {
    // locale
    final currentLocale = ref.read(activeLocaleProvider);
    final activeLocaleNotifier = ref.read(activeLocaleProvider.notifier);

    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(prefs_params.languageCodeKey);
    if (languageCode == null) {
      return true;
    }

    if (currentLocale.languageCode == languageCode) {
      return true;
    }

    final targetSupportedLanguage = SupportedLanguage.values.firstWhere(
      (element) => element.languageCode == languageCode,
      orElse: () => SupportedLanguage.en,
    );
    activeLocaleNotifier.set(targetSupportedLanguage);
    return false;
  }

  /// Currently, checks only version name (x.y.z).
  Future<void> _checkRequirements({bool ignore = false}) async {
    if (ignore) return;

    final errorTextColor = Theme.of(context).colorScheme.onError;
    final errorBgColor = Theme.of(context).colorScheme.error;

    // Fetch min requirements
    try {
      app_apis.minRequirements = await app_apis.getMinRequirements();
    } on Exception {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              actions: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: errorBgColor,
                  ),
                  icon: Icon(
                    Icons.close,
                    color: errorTextColor,
                  ),
                  label: Text(
                    _localizations.exit,
                    style: TextStyle(
                      color: errorTextColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
              content: SingleChildScrollView(
                child: Text(
                  _localizations.versionCompareFailureDialogContent,
                ),
              ),
            );
          },
        );
      }
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      rethrow;
    }

    final packageInfo = await PackageInfo.fromPlatform();

    final currrentVersionName = packageInfo.version;
    await _checkVersionName(currrentVersionName);
  }

  Future<void> _checkVersionName(String currrentVersionName) async {
    final errorTextColor = Theme.of(context).colorScheme.onError;
    final errorBgColor = Theme.of(context).colorScheme.error;
    final primaryTextColor = Theme.of(context).colorScheme.onPrimary;
    final primaryBgColor = Theme.of(context).colorScheme.primary;

    final int compareVersionName;
    try {
      compareVersionName = _compareSemanticVersion(
        currrentVersionName,
        app_apis.minRequirements['minVersionName'],
      );
    } on Exception {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              actions: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: errorBgColor,
                  ),
                  icon: Icon(
                    Icons.close,
                    color: errorTextColor,
                  ),
                  label: Text(
                    _localizations.exit,
                    style: TextStyle(
                      color: errorTextColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
              content: SingleChildScrollView(
                child: Text(
                  _localizations.versionCompareFailureDialogContent,
                ),
              ),
            );
          },
        );
      }
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      rethrow;
    }

    if (compareVersionName < 0) {
      // Needs upgrade
      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: primaryBgColor,
                  ),
                  icon: Icon(
                    Icons.upgrade,
                    color: primaryTextColor,
                  ),
                  label: Text(
                    _localizations.goToStore,
                    style: TextStyle(
                      color: primaryTextColor,
                    ),
                  ),
                  onPressed: () {
                    if (Platform.isAndroid) {
                      final url = Uri.parse('market://details?id=cards.carol');
                      launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: errorBgColor,
                  ),
                  icon: Icon(
                    Icons.close,
                    color: errorTextColor,
                  ),
                  label: Text(
                    _localizations.exit,
                    style: TextStyle(
                      color: errorTextColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
              title: Text(_localizations.needsUpgrade),
              content: SingleChildScrollView(
                child: Text(
                  _localizations.needsUpgradeContent,
                ),
              ),
            );
          },
        );
      }
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      throw Exception();
    }
  }

  /// Assumes semantic versioning. (e.g. '3.12.4')
  int _compareSemanticVersion(String current, String min) {
    final splitCurrent = current.split('.');
    final splitMin = min.split('.');
    if (splitCurrent.length != splitMin.length) {
      throw FormatException(
        'Provided semantic versions are not in the same format',
        {
          'current': current,
          'min': min,
        },
      );
    }
    for (var i = 0; i < splitCurrent.length; i++) {
      final compareTo =
          int.parse(splitCurrent[i]).compareTo(int.parse(splitMin[i]));
      if (compareTo == 0) {
        continue;
      }
      return compareTo;
    }
    return 0;
  }

  Future<void> _showAppNotices() async {
    // 1. GET /app/appNotice/list/id -> e.g. [6,8,9]
    final incomingIds = await app_apis.listAppNoticesId();

    // 2. compare with locally stored notices
    // 2.1. Parse notices in local storage
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedNotices = (prefs.getStringList(prefs_params.appNoticesKey) ??
            <String>[])
        .map((encodedNotice) => AppNotice.fromJson(json.decode(encodedNotice)))
        .toSet();
    final storedNoticeIds = storedNotices.map((e) => e.id).toSet();

    // 2.2. Split ids into groups
    final idsToFetch = <int>{};
    final storedNoticeIdsToShowCandidates = <int>{};
    for (final id in incomingIds) {
      if (storedNoticeIds.contains(id)) {
        storedNoticeIdsToShowCandidates.add(id);
        continue;
      }
      idsToFetch.add(id);
    }

    // 3. Fetch others: GET /app/appNotice/list
    final fetchedNotices = await app_apis.listAppNotices(ids: idsToFetch);

    // 4. Show notices
    // 4.1. Split notices into groups
    final noticesToSave = <AppNotice>[];
    final storedNoticesToShow = <AppNotice>[];
    for (final storedNotice in storedNotices) {
      if (storedNotice.isSuppressed) {
        noticesToSave.add(storedNotice);
        continue;
      }
      if (storedNoticeIdsToShowCandidates.contains(storedNotice.id)) {
        storedNoticesToShow.add(storedNotice);
      }
    }

    // 4.2. Merge local and fetched and sort by priority
    final noticesToShow = <AppNotice>[];
    noticesToShow.addAll(fetchedNotices);
    noticesToShow.addAll(storedNoticesToShow);
    noticesToShow.sort((a, b) => b.priority - a.priority);

    // 4.3. Show notices
    for (final notice in noticesToShow) {
      // 4.3.[].1. Show
      if (!mounted) continue;
      final suppress = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AppNoticeDialogScreen(notice: notice);
        },
      );

      // 4.3.[].2. Check suppress
      if (suppress != null && suppress) {
        noticesToSave.add(notice.copyWith(isSuppressed: true));
        continue;
      }
      noticesToSave.add(notice);
    }

    // 5. Save notices
    prefs.setStringList(
      prefs_params.appNoticesKey,
      noticesToSave
          .map((notice) => json.encode(
                notice.toJson(),
                toEncodable: customToEncodable,
              ))
          .toList(),
    );
  }

  Future<void> _tryAutoSignIn({bool ignore = false}) async {
    final currentUserNotifier = ref.read(currentUserProvider.notifier);

    if (ignore) {
      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.unauthenticated;
          _waiting = false;
        });
      }
      return;
    }

    // 1. Get stored credential
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final oidcString = prefs.getString(prefs_params.oidcKey);

    // 2. Validate credential
    if (oidcString == null) {
      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.unauthenticated;
          _waiting = false;
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
        text: '${_localizations.signInAgain}: $refreshTokenMsg',
        level: SnackBarLevel.warn,
      );
      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.unauthenticated;
          _waiting = false;
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
        contextMessage: _localizations.failedToAutoSignIn,
        localizations: _localizations,
      );
      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.unauthenticated;
          _waiting = false;
        });
      }
      return;
    }

    if (newOidc == null) {
      // Got invalid OIDC
      prefs.remove(prefs_params.oidcKey);
      Carol.showTextSnackBar(
        text: _localizations.failedToAutoSignIn,
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
    prefs.setString(prefs_params.oidcKey, json.encode(newOidc));

    // 5. Navigate to DashboardScreen
    if (mounted) {
      setState(() {
        _authStatus = AuthStatus.authenticated;
        _waiting = false;
      });
    }

    // Set User
    final currentUser = User(
      oidc: newOidc,
      profileImageUrl: null,
    );
    currentUserNotifier.set(currentUser);
    // developer.log('[+]access token: ${newOidc['access_token']}');

    if (!mounted) return;
    _loadInitialModels();

    // Next Screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);

    final autoSignInSection = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: DesignUtils.basicWidgetEdgeInsets(),
          child: Text(
            _localizations.rememberMe,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        // const SizedBox(width: 10),
        Switch(
          value: _isAutoSignInEnabled,
          onChanged: _waiting || _authStatus == AuthStatus.authenticating
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
      disabledBackgroundColor: Theme.of(context).colorScheme.background,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
    if (_waiting) {
      authButton = ElevatedButton(
        onPressed: null,
        style: authButtonStyle,
        child: Text(
          _localizations.pleaseWait,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      );
    } else if (_authStatus == AuthStatus.unauthenticated) {
      authButton = ElevatedButton(
        onPressed: _onPressSignIn,
        style: authButtonStyle,
        child: Text(
          _localizations.signInUp,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    } else if (_authStatus == AuthStatus.authenticating) {
      authButton = ElevatedButton(
        onPressed: _onPressCancelAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
        child: Text(
          _localizations.abortSignInUp,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      );
    } else {
      // authStatus == AuthStatus.authenticated
      authButton = ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
          );
        },
        style: authButtonStyle,
        child: Text(
          '${_localizations.youAreSignedIn}, ${currentUser!.displayName}!',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: Container(
                margin: DesignUtils.basicScreenEdgeInsets(ctx, constraints),
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
                    SizedBox(
                      width: 400,
                      // height: 300,
                      child: Card(
                        margin: const EdgeInsets.all(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Padding(
                            padding: DesignUtils.basicWidgetEdgeInsets(2),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        DesignUtils.basicWidgetEdgeInsets(),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _localizations.welcomeTo,
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
                                          _localizations.carolCards,
                                          textAlign: TextAlign.center,
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
                                    padding:
                                        DesignUtils.basicWidgetEdgeInsets(),
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
                      ),
                    ),
                    LanguageDropdownButton(
                      textColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPressSignIn() async {
    // final authStatusNotifier = ref.read(authStatusProvider.notifier);
    if (mounted) {
      setState(() {
        _authStatus = AuthStatus.authenticating;
      });
    }

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
    // final authStatusNotifier = ref.read(authStatusProvider.notifier);
    // final isAutoSignInEnabled = ref.read(autoSignInEnabledProvider);
    final currentUserNotifier = ref.read(currentUserProvider.notifier);

    if (_pkcePair == null) {
      Carol.showTextSnackBar(
        text: _localizations.lostPkceData,
        level: SnackBarLevel.error,
      );
      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.unauthenticated;
        });
      }
      return;
    }

    // Verify state
    final state = uri.queryParameters['state'];
    if (state != _stateToken) {
      Carol.showTextSnackBar(
        text: _localizations.invalidStateToken,
        level: SnackBarLevel.error,
      );
      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.unauthenticated;
        });
      }
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
        Carol.showTextSnackBar(
          text:
              '${_localizations.failedToAuthenticate}${invalidOidcMsgs.fold('\n- ', (prev, cur) => '$prev\n- $cur')}',
          level: SnackBarLevel.error,
        );
        if (mounted) {
          setState(() {
            _authStatus = AuthStatus.unauthenticated;
          });
        }
        return;
      }

      // Store credential if auto sign in is enabled
      final prefs = await SharedPreferences.getInstance();
      if (_isAutoSignInEnabled) {
        prefs.setString(prefs_params.oidcKey, res.body);
      } else {
        // Try removing credential if auto sign in is disabled
        prefs.remove(prefs_params.oidcKey);
      }

      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.authenticated;
        });
      }
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToSignIn,
        localizations: _localizations,
      );
      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.unauthenticated;
        });
      }
      return;
    }

    // developer.log('[+]access token: ${oidc['access_token']}');

    currentOidc = oidc;

    // Set User
    final currentUser = User(
      oidc: oidc,
      profileImageUrl: null,
    );
    currentUserNotifier.set(currentUser);

    if (!mounted) return;
    _loadInitialModels();

    // Next Screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  void _onPressCancelAuth() {
    setState(() {
      _authStatus = AuthStatus.unauthenticated;
    });
    ref.read(currentUserProvider.notifier).set(null);
  }

  Future<void> _loadInitialModels() async {
    // Load Init Entities: Landing page is CustomerScreen, so load Customer Cards and Stores
    try {
      await customer_apis.reloadCustomerModels(ref);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToLoadCustomerModels,
        localizations: _localizations,
      );
    }
  }
}
