import 'dart:async';
import 'dart:convert';
import 'package:carol/apis/auth_apis.dart';
import 'package:carol/providers/auth_status_provider.dart';
import 'package:carol/providers/auto_sign_in_enabled_provider.dart';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import 'package:carol/apis/utils.dart';
import 'package:carol/params.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/customer_screen.dart';
import 'package:carol/screens/owner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 172, 241, 43),
  background: const Color.fromARGB(255, 56, 49, 66),
);

final theme = ThemeData().copyWith(
  useMaterial3: true,
  scaffoldBackgroundColor: colorScheme.background,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
  ),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(const ProviderScope(child: Carol()));
  });
}

class Carol extends ConsumerStatefulWidget {
  const Carol({Key? key}) : super(key: key);

  static GlobalKey<NavigatorState> materialKey = GlobalKey();

  @override
  ConsumerState<Carol> createState() => _CarolState();

  static void showTextSnackBar({
    required String text,
    int seconds = 3,
    SnackBarLevel level = SnackBarLevel.info,
  }) {
    ScaffoldMessenger.of(Carol.materialKey.currentContext!)
        .showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: seconds),
    ));
  }
}

class _CarolState extends ConsumerState<Carol> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carol Cards',
      theme: theme,
      // Warning: When using initialRoute, don’t define a home property.
      // home: const AuthScreen(),
      navigatorKey: Carol.materialKey,
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/customer': (context) => CustomerScreen(),
        '/owner': (context) => const OwnerScreen(),
      },
    );
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      await handleAppLink(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      handleAppLink(uri);
    });
  }

  Future<void> handleAppLink(Uri uri) async {
    if (uri.path == '/callback') {
      print('[+]Handling /callback');
      return handleCallback(uri);
    }
  }

  Future<void> handleCallback(Uri uri) async {
    final authStatusNotifier = ref.read(authStatusProvider.notifier);
    final isAutoSignInEnabled = ref.read(autoSignInEnabledProvider);

    if (originalPkcePair == null) {
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
    if (state != originalState) {
      Carol.showTextSnackBar(
        text: 'Invalid state token',
        level: SnackBarLevel.error,
      );
      authStatusNotifier.set(AuthStatus.unauthenticated);
      // Pop all
      Navigator.of(context).popUntil(ModalRoute.withName('/auth'));
      return;
    }

    // final sessionState = uri.queryParameters['session_state'];

    // Exchange code
    final code = uri.queryParameters['code'];
    try {
      final res = await httpPost(
        tokenEndpoint,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        },
        body: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'code': code,
          'code_verifier': originalPkcePair!.codeVerifier,
          'redirect_uri': redirectUri,
        },
      );
      final oidc = json.decode(res.body);

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
      if (isAutoSignInEnabled) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userCredential', res.body);
      }

      authStatusNotifier.set(AuthStatus.authenticated);
    } on Exception catch (e) {
      authStatusNotifier.set(AuthStatus.unauthenticated);
      Carol.showTextSnackBar(
        text: e.toString(),
        seconds: 10,
        level: SnackBarLevel.error,
      );
      return;
    }
  }
}

enum SnackBarLevel {
  success,
  info,
  warn,
  error,
}
