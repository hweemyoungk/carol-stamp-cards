import 'dart:async';
import 'dart:io';

import 'package:carol/apis/exceptions/bad_request.dart';
import 'package:carol/apis/exceptions/server_error.dart';
import 'package:carol/apis/exceptions/unauthenticated.dart';
import 'package:carol/apis/exceptions/unauthorized.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/blueprint_dialog_screen.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/screens/customer_design_stamp_card_screen.dart';
import 'package:carol/screens/customer_screen.dart';
import 'package:carol/screens/dashboard_screen.dart';
import 'package:carol/screens/owner_design_blueprint_screen.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/screens/owner_scan_qr_screen.dart';
import 'package:carol/screens/owner_screen.dart';
import 'package:carol/screens/store_screen.dart';
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
        '/customer': (context) => CustomerScreen(),
        '/customer#cards-explorer#cards-list#cards-list-item/card': (context) =>
            const CardScreen(),
        '/dashboard/customer/card/modify': (context) =>
            const CustomerDesignStampCardScreen(),
        '/customer/card/store': (context) => const StoreScreen(),
        '/customer#stores-explorer#stores-list#stores-list-item/store':
            (context) => const StoreScreen(),
        '/customer/store/blueprint-dialog': (context) =>
            const BlueprintDialogScreen(
              blueprintDialogMode: BlueprintDialogMode.customer,
            ),
        '/owner': (context) => OwnerScreen(),
        '/owner#stores-explorer#stores-list/new-store': (context) =>
            const OwnerDesignStoreScreen(
              designMode: StoreDesignMode.create,
            ),
        '/owner/scan-qr': (context) => const OwnerScanQrScreen(),
        // TODO
        // '/owner#rr-explorer#rr-list#rr-list-item/redeem-request-dialog': (context) => const RedeemRequestDialogScreen(),
        '/owner#stores-explorer#stores-list#stores-item/store': (context) =>
            const StoreScreen(),
        '/owner/store/modify': (context) => const OwnerDesignStoreScreen(
              designMode: StoreDesignMode.modify,
            ),
        '/owner/store/new-blueprint': (context) =>
            const OwnerDesignBlueprintScreen(
              designMode: BlueprintDesignMode.create,
            ),
        '/owner/store/blueprint-dialog': (context) =>
            const BlueprintDialogScreen(
              blueprintDialogMode: BlueprintDialogMode.owner,
            ),
        '/owner/store/blueprint-dialog/modify': (context) =>
            const OwnerDesignBlueprintScreen(
              designMode: BlueprintDesignMode.modify,
              // originalBlueprint: blueprint,
            ),
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

  static void showExceptionSnackBar(Exception e, {String? contextMessage}) {
    final sb = StringBuffer();
    if (contextMessage != null) {
      sb
        ..write(contextMessage)
        ..write('\n');
    }
    if (e is ServerError) {
      sb.write(
          'Server failed to process your data. Please contact administrator if this problem persists.');
      showTextSnackBar(
        text: sb.toString(),
        level: SnackBarLevel.error,
        seconds: 10,
      );
      return;
    }
    if (e is BadRequest) {
      sb.write('Your data looks stale. Please refresh and try again.');
      showTextSnackBar(
        text: sb.toString(),
        level: SnackBarLevel.error,
        seconds: 10,
      );
      return;
    }
    if (e is Unauthenticated || e is Unauthorized) {
      sb.write('Your credential looks stale. Please sign in again.');
      showTextSnackBar(
        text: sb.toString(),
        level: SnackBarLevel.error,
        seconds: 10,
      );
      return;
    }
    if (e is TimeoutException) {
      sb.write('Server looks busy. Please wait a while and try again.');
      showTextSnackBar(
        text: sb.toString(),
        level: SnackBarLevel.warn,
        seconds: 10,
      );
      return;
    }
    if (e is SocketException) {
      sb.write('Server is under maintenance. Please wait a while try again.');
      showTextSnackBar(
        text: sb.toString(),
        level: SnackBarLevel.warn,
        seconds: 10,
      );
      return;
    }
    sb.write('Unexpected error occured: ${e.toString()}');
    showTextSnackBar(
      text: sb.toString(),
      level: SnackBarLevel.error,
      seconds: 10,
    );
  }

  static void customerPropagateCard(StampCard newCard) {
    // TODO: Implement
  }
}

enum SnackBarLevel {
  success,
  info,
  warn,
  error,
  debug,
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
      case SnackBarLevel.debug:
        return theme.colorScheme.secondaryContainer;
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
      case SnackBarLevel.debug:
        return theme.colorScheme.onSecondaryContainer;
      default:
        return theme.colorScheme.onBackground;
    }
  }
}
