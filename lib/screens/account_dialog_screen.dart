import 'package:carol/apis/auth_apis.dart' as auth_apis;
import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/store.dart';
import 'package:carol/params/athena.dart';
import 'package:carol/params/shared_preferences.dart' as prefs_params;
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/blueprint_dialog_screen.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/screens/customer_design_stamp_card_screen.dart';
import 'package:carol/screens/redeem_request_dialog_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/common/alert_row.dart';
import 'package:carol/widgets/common/proceed_alert_dialog.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_list.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDialogScreen extends ConsumerStatefulWidget {
  const AccountDialogScreen({
    super.key,
  });

  @override
  ConsumerState<AccountDialogScreen> createState() =>
      _AccountDialogScreenState();
}

class _AccountDialogScreenState extends ConsumerState<AccountDialogScreen> {
  final List<Widget> _deleteAccountAlertRows = [];
  bool? _canDeleteAccount;

  @override
  void initState() {
    super.initState();
    _checkCanDeleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      content: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _signOut,
              child: const Text('Sign out'),
            ),
            ElevatedButton(
              onPressed: _onPressEditAccount,
              child: const Text('Edit account'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: _canDeleteAccount == null
                    ? null
                    : _canDeleteAccount!
                        ? null
                        : Theme.of(context)
                            .colorScheme
                            .onErrorContainer
                            .withOpacity(0.5),
              ),
              onPressed: _canDeleteAccount == null
                  ? null
                  : _canDeleteAccount!
                      ? _onPressDeleteAccount
                      : _onPressDeleteAccountViolated,
              child: Text(
                'Delete account',
                style: TextStyle(
                  color: _canDeleteAccount != null && !_canDeleteAccount!
                      ? Theme.of(context)
                          .colorScheme
                          .onErrorContainer
                          .withOpacity(0.5)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPressEditAccount() async {
    final url = Uri.https(keycloakHostname, accountPath);
    await launchInBrowserView(url);
  }

  Future<void> _onPressDeleteAccount() async {
    final currentUser = ref.read(currentUserProvider);
    final currentUserNotifier = ref.read(currentUserProvider.notifier);

    final proceed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => ProceedAlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This cannot be undo.'),
        proceedButtonString: 'Delete',
        proceedButtonStringColor: Theme.of(context).colorScheme.onError,
        proceedButtonColor: Theme.of(context).colorScheme.error,
      ),
    );
    if (proceed == null || !proceed) {
      return;
    }

    try {
      await auth_apis.deleteAccount(userId: currentUser!.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to delete account.',
      );
      return;
    }
    // Propagate

    Carol.showTextSnackBar(
      text: 'Deleted account!',
      level: SnackBarLevel.success,
    );

    // Sign out
    currentUserNotifier.set(null);
    await _signOut();
  }

  Future<void> _checkCanDeleteAccount() async {
    // Reset
    setState(() {
      _canDeleteAccount = null;
      _deleteAccountAlertRows.clear();
    });

    if (await _validateDeleteAccount()) {
      setState(() {
        _canDeleteAccount = true;
      });
    }
  }

  Future<bool> _validateDeleteAccount() async {
    final violated = await _violatedOwnerResources();
    return !violated;
  }

  Future<bool> _violatedOwnerResources() async {
    // Check owner membership exists
    final user = ref.read(currentUserProvider);
    if (user?.ownerMembership == null) {
      return false;
    }

    // Check all owner resources are inactive
    final Set<Store> stores;
    try {
      stores = await owner_apis.listStores(ownerId: user!.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to load owner models.',
      );
      _deleteAccountAlertRows.add(const AlertRow(
        text: 'Failed to load owner models.',
      ));
      if (mounted) {
        setState(() {
          _canDeleteAccount = false;
        });
      }
      return true;
    }

    final activeStores = stores.where((element) => !element.isInactive);
    if (activeStores.isNotEmpty) {
      _deleteAccountAlertRows.add(AlertRow(
        text: 'Following stores still exist.${activeStores.fold(
          '',
          (previousValue, element) =>
              '$previousValue\n- ${element.displayName}',
        )}',
      ));
      if (mounted) {
        setState(() {
          _canDeleteAccount = false;
        });
      }
      return true;
    }

    return false;
  }

  void _onPressDeleteAccountViolated() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cannot delete account'),
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _deleteAccountAlertRows,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    // Revoke token
    currentOidc.clear();

    // Remove stored credentials
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(prefs_params.oidcKey);

    _resetAllProviders();

    Carol.materialKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
      (route) => false,
    );
  }

  void _resetAllProviders() {
    if (!mounted) return;
    ref.read(activeDrawerItemProvider.notifier).set(DrawerItemEnum.customer);
    ref.read(currentUserProvider.notifier).set(null);
    ref.read(customerCardsListCardsProvider.notifier).set(null);
    ref.read(customerStoresListStoresProvider.notifier).set(null);
    ref.read(customerCardScreenCardProvider.notifier).set(null);
    ref.read(customerDesignCardScreenBlueprintProvider.notifier).set(null);
    ref.read(customerStoreScreenStoreProvider.notifier).set(null);
    ref.read(customerBlueprintDialogScreenBlueprintProvider.notifier).set(null);
    ref.read(ownerStoresListStoresProvider.notifier).set(null);
    ref.read(ownerRedeemRequestsListRedeemRequestsProvider.notifier).set(null);
    ref.read(ownerRedeemRequestDialogRedeemRequestProvider.notifier).set(null);
    ref.read(ownerStoreScreenStoreProvider.notifier).set(null);
    ref.read(ownerBlueprintDialogScreenBlueprintProvider.notifier).set(null);
  }
}
