import 'package:carol/apis/auth_apis.dart';
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/params/athena.dart';
import 'package:carol/params/shared_preferences.dart'
    as shared_preferences_params;
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/widgets/common/proceed_alert_dialog.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Screen')),
      drawer: const MainDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _onPressEditAccount,
              child: const Text('Edit account'),
            ),
            ElevatedButton(
              onPressed: _onPressDeleteAccount,
              child: const Text('Delete account'),
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
    _validateDeleteAccount();

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
      await deleteAccount(userId: currentUser!.id);
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

  void _validateDeleteAccount() {
    // TODO: Implement
  }

  Future<void> _signOut() async {
    // Revoke token
    currentOidc.clear();
    // Remove stored credentials
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(shared_preferences_params.oidcKey);
    // TODO: Remove all models and reset all providers

    // TODO: Go to AuthScreen regardless of context.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
      (route) => false,
    );
  }
}
