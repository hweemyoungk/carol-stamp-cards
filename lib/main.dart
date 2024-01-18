import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

class Carol extends StatelessWidget {
  const Carol({Key? key}) : super(key: key);

  static GlobalKey<NavigatorState> materialKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carol Cards',
      theme: theme,
      navigatorKey: materialKey,
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }

  static void showTextSnackBar({
    required String text,
    int seconds = 3,
    SnackBarLevel level = SnackBarLevel.info,
  }) {
    ScaffoldMessenger.of(Carol.materialKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(color: level.textColor),
        ),
        duration: Duration(seconds: seconds),
        backgroundColor: level.backgroundColor,
      ),
    );
  }
}

enum SnackBarLevel {
  success,
  info,
  warn,
  error,
}

extension SnackBarLevelExtension on SnackBarLevel {
  Color get backgroundColor {
    switch (this) {
      case SnackBarLevel.success:
        return theme.colorScheme.primary;
      case SnackBarLevel.error:
        return theme.colorScheme.error;
      case SnackBarLevel.warn:
        return theme.colorScheme.errorContainer;
      default:
        return theme.colorScheme.background;
    }
  }

  Color get textColor {
    switch (this) {
      case SnackBarLevel.success:
        return theme.colorScheme.onPrimary;
      case SnackBarLevel.error:
        return theme.colorScheme.onError;
      case SnackBarLevel.warn:
        return theme.colorScheme.onErrorContainer;
      default:
        return theme.colorScheme.onBackground;
    }
  }
}
