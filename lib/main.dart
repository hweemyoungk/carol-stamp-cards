import 'dart:async';
import 'dart:io';

import 'package:carol/apis/dev_http_overrides.dart';
import 'package:carol/apis/exceptions/bad_request.dart';
import 'package:carol/apis/exceptions/server_error.dart';
import 'package:carol/apis/exceptions/unauthenticated.dart';
import 'package:carol/apis/exceptions/unauthorized.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/blueprint_dialog_screen.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/screens/customer_design_stamp_card_screen.dart';
import 'package:carol/screens/customer_screen.dart';
import 'package:carol/screens/dashboard_screen.dart';
import 'package:carol/screens/owner_design_blueprint_screen.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/screens/owner_screen.dart';
import 'package:carol/screens/scan_qr_screen.dart';
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
  textTheme: GoogleFonts.ubuntuCondensedTextTheme(),
  // textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
  //   titleSmall: GoogleFonts.ubuntuCondensed(
  //     fontWeight: FontWeight.bold,
  //   ),
  //   titleMedium: GoogleFonts.ubuntuCondensed(
  //     fontWeight: FontWeight.bold,
  //   ),
  //   titleLarge: GoogleFonts.ubuntuCondensed(
  //     fontWeight: FontWeight.bold,
  //   ),
  // ),
);

void main() {
  HttpOverrides.global = DevHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) async {
    runApp(const ProviderScope(child: Carol()));
  });
}

class Carol extends StatefulWidget {
  const Carol({Key? key}) : super(key: key);

  static GlobalKey<NavigatorState> materialKey = GlobalKey();

  @override
  State<Carol> createState() => _CarolState();

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
}

class _CarolState extends State<Carol> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carol Cards',
      theme: theme,
      navigatorKey: Carol.materialKey,
      initialRoute: '/auth',
      routes: {
        // currentUserProvider
        '/auth': (context) => const AuthScreen(), // Done with default
        // No providers
        '/dashboard': (context) => const DashboardScreen(), // No notification
        // customerCardsListCardsProvider
        // customerStoresListStoresProvider
        '/dashboard#customer': (context) =>
            CustomerScreen(), // Done by AuthScreen._loadInitialModels()
        // customerCardsListCardsProvider
        // customerStoresListStoresProvider
        // customerCardScreenCardProvider
        '/dashboard#customer#cards-list/card': (context) =>
            const CardScreen(), // Done by _notifyCardScreen()
        // customerCardsListCardsProvider
        // customerStoresListStoresProvider
        // customerCardScreenCardProvider
        // '/dashboard#customer#cards-list/card': (context) => const RedeemDialogScreen(card: card, redeemRule: redeemRule),
        // customerCardsListCardsProvider
        // customerStoresListStoresProvider
        // customerCardScreenCardProvider
        // customerDesignCardScreenBlueprintProvider
        '/dashboard#customer#cards-list/card/modify': (context) =>
            const CustomerDesignStampCardScreen(), // Done by _notifyCustomerDesignStampCardScreen()
        // customerCardsListCardsProvider
        // customerStoresListStoresProvider
        // customerCardScreenCardProvider
        // customerStoreScreenStoreProvider
        '/dashboard#customer#cards-list/card/store': (context) =>
            const StoreScreen(), // Done by _notifyStoreScreen()
        // customerCardsListCardsProvider
        // customerStoresListStoresProvider
        '/dashboard#customer#stores-list/scan-qr': (context) =>
            const ScanQrScreen(),
        // customerCardsListCardsProvider
        // customerStoresListStoresProvider
        // customerStoreScreenStoreProvider
        '/dashboard#customer#stores-list/store': (context) =>
            const StoreScreen(), // Done by StoresListItem._notifyStoreScreen()
        // customerCardsListCardsProvider
        // customerStoresListStoresProvider
        // customerStoreScreenStoreProvider
        // customerBlueprintDialogScreenBlueprintProvider
        '/dashboard#customer#stores-list/store/blueprint-dialog': (context) =>
            const BlueprintDialogScreen(
              blueprintDialogMode: BlueprintDialogMode.customer,
            ), // Done by StoreScreen._notifyBlueprintDialogScreen(Blueprint)
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        '/dashboard/owner': (context) =>
            OwnerScreen(), // Done by DrawerItem._initLoadEntities()
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        '/dashboard/owner/scan-qr': (context) =>
            const ScanQrScreen(), // No notification
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        // ownerRedeemRequestDialogRedeemRequestProvider
        // '/dashboard/owner#rr-list/redeem-request-dialog': (context) => const RedeemRequestDialogScreen(), // Done by RedeemRequestsListItem._notifyRedeemRequestDialogScreen()
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        '/dashboard/owner#stores-list/new-store': (context) =>
            const OwnerDesignStoreScreen(
                designMode: StoreDesignMode.create), // No notification
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        // ownerStoreScreenStoreProvider
        '/dashboard/owner#stores-list/store': (context) =>
            const StoreScreen(), // Done by StoresListItem._notifyStoreScreen()
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        // ownerStoreScreenStoreProvider
        '/dashboard/owner#stores-list/store/modify': (context) =>
            const OwnerDesignStoreScreen(
              designMode: StoreDesignMode.modify,
            ), // No notification
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        // ownerStoreScreenStoreProvider
        '/dashboard/owner#stores-list/store/new-blueprint': (context) =>
            const OwnerDesignBlueprintScreen(
              designMode: BlueprintDesignMode.create,
            ), // No notification
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        // ownerStoreScreenStoreProvider
        // ownerBlueprintDialogScreenBlueprintProvider
        '/dashboard/owner#stores-list/store/blueprint-dialog': (context) =>
            const BlueprintDialogScreen(
              blueprintDialogMode: BlueprintDialogMode.owner,
            ), // Done by StoreScreen._notifyBlueprintDialogScreen(Blueprint)
        // ownerStoresListStoresProvider
        // Ignore: ownerRedeemRequestsListRedeemRequestsProvider
        // ownerStoreScreenStoreProvider
        // ownerBlueprintDialogScreenBlueprintProvider
        '/dashboard/owner#stores-list/store/blueprint-dialog/modify':
            (context) => const OwnerDesignBlueprintScreen(
                  designMode: BlueprintDesignMode.modify,
                  // originalBlueprint: blueprint,
                ), // No notification
      },
    );
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
