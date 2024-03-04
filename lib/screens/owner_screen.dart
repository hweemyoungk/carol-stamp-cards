import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/user.dart';
import 'package:carol/params/app.dart' as app_params;
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/screens/scan_qr_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/alert_row.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_explorer.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_list.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool isOwnerModelsInitLoaded(WidgetRef ref) {
  return ref.read(ownerStoresListStoresProvider) != null;
}

class OwnerScreen extends ConsumerStatefulWidget {
  OwnerScreen({super.key});

  final ownerScreenBodies = {
    0: const StoresExplorer(),
    1: const RedeemRequestsExplorer(),
  };

  @override
  ConsumerState<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends ConsumerState<OwnerScreen> {
  final List<Widget> _newStoreAlertRows = [];

  late AppLocalizations _localizations;
  int _activeBottomItemIndex = 0;
  bool _isRefreshStoresCooling = false;
  bool _isRefreshRedeemRequestsCooling = false;
  bool? _canCreateNewStore;
  // bool _isReloadingStores = false;

  @override
  void initState() {
    super.initState();

    // Initial bottom item is StoresExplorer.
    _checkCanCreateNewStore();
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: widget.ownerScreenBodies[_activeBottomItemIndex]!,
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: IconButton.filled(
              iconSize: 100,
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _onPressScanQr,
            ),
          )
        ],
      ),
      appBar: AppBar(
        title: Text(_localizations.ownersScreenAppBarTitle),
        actions: _getAppBarActions(),
      ),
      drawer: const MainDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeBottomItemIndex,
        onTap: _onTapBottomItem,
        items: [
          BottomNavigationBarItem(
            label: _localizations.stores,
            icon: const Icon(Icons.store),
          ),
          BottomNavigationBarItem(
            label: _localizations.redeemRequests,
            icon: const Icon(Icons.approval),
          ),
        ],
      ),
    );
  }

  void _onPressNewStore() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return !isSavingStore;
        },
        child: const OwnerDesignStoreScreen(
          designMode: StoreDesignMode.create,
        ),
      ),
    ));
    _checkCanCreateNewStore();
  }

  void _onPressNewStoreViolated() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(_localizations.cannotCreateStore),
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _newStoreAlertRows,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPressScanQr() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ScanQrScreen(),
    ));
    // final qr =
    //     await Navigator.of(context).push<SimpleStampCardQr>(MaterialPageRoute(
    //   builder: (context) => const OwnerScanQrScreen(),
    // ));
    // if (qr == null) {
    //   return;
    // }
    // Carol.showTextSnackBar(text: 'Got stamp card id: ${qr.stampCardId}');
  }

  void _onTapBottomItem(int value) {
    setState(() {
      _activeBottomItemIndex = value;
    });

    if (value == 1) {
      // RedeemRequestExplorer
      final ownerRedeemRequestsInitLoaded =
          ref.read(ownerRedeemRequestsListRedeemRequestsProvider) != null;
      if (!ownerRedeemRequestsInitLoaded) {
        _reloadOwnerRedeemRequests();
      }
    }
  }

  List<Widget>? _getAppBarActions() {
    if (_activeBottomItemIndex == 0) {
      return [
        IconButton(
          onPressed: _canCreateNewStore == null
              ? null
              : _canCreateNewStore!
                  ? _onPressNewStore
                  : _onPressNewStoreViolated,
          icon: Icon(
            Icons.add,
            color: _canCreateNewStore == null || _canCreateNewStore!
                ? null
                : Theme.of(context).colorScheme.error.withOpacity(0.5),
          ),
        ),
        _isRefreshStoresCooling
            ? const IconButton(
                onPressed: null,
                icon: Icon(Icons.refresh),
              )
            : IconButton(
                onPressed: _onPressRefreshStores,
                icon: const Icon(Icons.refresh),
              ),
      ];
    } else {
      return [
        IconButton(
          onPressed: _onPressAboutRedeemRequests,
          icon: const Icon(Icons.help),
        ),
        _isRefreshRedeemRequestsCooling
            ? const IconButton(
                onPressed: null,
                icon: Icon(Icons.refresh),
              )
            : IconButton(
                onPressed: _onPressRefreshRedeemRequests,
                icon: const Icon(Icons.refresh),
              ),
      ];
    }
  }

  Future<void> _reloadOwnerRedeemRequests() async {
    final currentUser = ref.read(currentUserProvider)!;
    final redeemRequestsNotifier =
        ref.read(ownerRedeemRequestsListRedeemRequestsProvider.notifier);
    redeemRequestsNotifier.set(null);

    final Set<RedeemRequest> redeemRequests;
    try {
      redeemRequests =
          await owner_apis.listRedeemRequests(ownerId: currentUser.id);
    } on Exception catch (e) {
      redeemRequestsNotifier.set([]);
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToLoadRedeemRequests,
        localizations: _localizations,
      );
      return;
    }
    // Propagate
    // ownerRedeemRequestsListRedeemRequestsProvider
    redeemRequestsNotifier.set(redeemRequests.toList());
  }

  Future<void> _onPressRefreshStores() async {
    _setRefreshStoresCooling();
    await owner_apis.reloadOwnerModels(ref);

    // Refresh _canCreateNewStore
    _checkCanCreateNewStore();
  }

  Future<void> _setRefreshStoresCooling() async {
    if (!mounted) return;
    setState(() {
      _isRefreshStoresCooling = true;
    });
    await Future.delayed(refreshCoolingDuration);
    if (!mounted) return;
    setState(() {
      _isRefreshStoresCooling = false;
    });
  }

  Future<void> _onPressRefreshRedeemRequests() async {
    _setRefreshRedeemRequestsCooling();
    _reloadOwnerRedeemRequests();
  }

  Future<void> _setRefreshRedeemRequestsCooling() async {
    if (!mounted) return;
    setState(() {
      _isRefreshRedeemRequestsCooling = true;
    });
    await Future.delayed(refreshOwnerRedeemRequestsListCoolingDuration);
    if (!mounted) return;
    setState(() {
      _isRefreshRedeemRequestsCooling = false;
    });
  }

  Future<void> _checkCanCreateNewStore() async {
    final user = ref.read(currentUserProvider)!;

    setState(() {
      _newStoreAlertRows.clear();
      _canCreateNewStore = null;
    });

    // Check owner membership
    if (_violatedMembershipExists(user)) {
      return;
    }

    final violatedNumMaxAccumulatedTotalStoresTask =
        _violatedNumMaxAccumulatedTotalStores(user: user);
    final violatedNumMaxCurrentTotalStoresTask =
        _violatedNumMaxCurrentTotalStores(user: user);
    final violatedNumMaxCurrentActiveStoresTask =
        _violatedNumMaxCurrentActiveStores(user: user);
    final tasks = [
      violatedNumMaxAccumulatedTotalStoresTask,
      violatedNumMaxCurrentTotalStoresTask,
      violatedNumMaxCurrentActiveStoresTask,
    ];
    final violations = await Future.wait(tasks);
    if (violations.every((violated) => !violated)) {
      if (mounted) {
        setState(() {
          _canCreateNewStore = true;
        });
      }
    }
  }

  bool _violatedMembershipExists(User user) {
    if (user.customerMembership == null) {
      Carol.showTextSnackBar(
        text: _localizations.cannotFindOwnerMembership,
        level: SnackBarLevel.error,
      );
      if (mounted) {
        setState(() {
          _canCreateNewStore = false;
          _newStoreAlertRows.add(AlertRow(
            text: _localizations.cannotFindOwnerMembership,
          ));
        });
      }
      return true;
    }
    return false;
  }

  /// Checks <code>@Min(-1) numMaxAccumulatedTotalStores</code>.
  Future<bool> _violatedNumMaxAccumulatedTotalStores({
    required User user,
  }) async {
    // Check infinity
    final numMaxAccumulatedTotalStores =
        user.ownerMembership!.numMaxAccumulatedTotalStores;
    if (numMaxAccumulatedTotalStores == -1) return false;

    final int numAccumulatedTotalStores;
    try {
      numAccumulatedTotalStores =
          await owner_apis.getNumAccumulatedTotalStores(ownerId: user.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToLoadNumAccumulatedTotalStores,
        localizations: _localizations,
      );
      if (mounted) {
        setState(() {
          _canCreateNewStore = false;
          _newStoreAlertRows.add(AlertRow(
            text: _localizations.failedToLoadNumAccumulatedTotalStores,
          ));
        });
      }
      return true;
    }

    final violated = numMaxAccumulatedTotalStores <= numAccumulatedTotalStores;
    if (violated) {
      if (mounted) {
        setState(() {
          _canCreateNewStore = false;
          _newStoreAlertRows.add(AlertRow(
            text: _localizations.reachedMaxNumAccumulatedTotalStores,
          ));
        });
      }
    }
    return violated;
  }

  /// Checks <code>@Min(-1) numMaxCurrentTotalStores;</code>.
  Future<bool> _violatedNumMaxCurrentTotalStores({
    required User user,
  }) async {
    // Check infinity
    final numMaxCurrentTotalStores =
        user.ownerMembership!.numMaxCurrentTotalStores;
    if (numMaxCurrentTotalStores == -1) return false;

    final int numCurrentTotalStores;
    try {
      numCurrentTotalStores =
          await owner_apis.getNumCurrentTotalStores(ownerId: user.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToLoadNumCurrentTotalStores,
        localizations: _localizations,
      );
      if (mounted) {
        setState(() {
          _canCreateNewStore = false;
          _newStoreAlertRows.add(AlertRow(
            text: _localizations.failedToLoadNumCurrentTotalStores,
          ));
        });
      }
      return true;
    }

    final violated = numMaxCurrentTotalStores <= numCurrentTotalStores;
    if (violated) {
      if (mounted) {
        setState(() {
          _canCreateNewStore = false;
          _newStoreAlertRows.add(AlertRow(
            text: _localizations.reachedMaxNumCurrentTotalStores,
          ));
        });
      }
    }
    return violated;
  }

  /// Checks <code>@Min(-1) numMaxCurrentActiveStores;</code>.
  Future<bool> _violatedNumMaxCurrentActiveStores({
    required User user,
  }) async {
    // Check infinity
    final numMaxCurrentActiveStores =
        user.ownerMembership!.numMaxCurrentActiveStores;
    if (numMaxCurrentActiveStores == -1) return false;

    final int numCurrentActiveStores;
    try {
      numCurrentActiveStores =
          await owner_apis.getNumCurrentActiveStores(ownerId: user.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToLoadNumCurrentActiveStores,
        localizations: _localizations,
      );
      if (mounted) {
        setState(() {
          _canCreateNewStore = false;
          _newStoreAlertRows.add(AlertRow(
            text: _localizations.failedToLoadNumCurrentActiveStores,
          ));
        });
      }
      return true;
    }

    final violated = numMaxCurrentActiveStores <= numCurrentActiveStores;
    if (violated) {
      if (mounted) {
        setState(() {
          _canCreateNewStore = false;
          _newStoreAlertRows.add(AlertRow(
            text: _localizations.reachedMaxNumCurrentActiveStores,
          ));
        });
      }
    }
    return violated;
  }

  void _onPressAboutRedeemRequests() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(_localizations.aboutRedeemRequestDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_localizations.whatIsRedeemRequest,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(_localizations.redeemRequestExplanationItem1),
                Text(_localizations.redeemRequestExplanationItem2),
                Text(_localizations.redeemRequestExplanationItem3(formatSeconds(
                  app_params.watchRedeemRequestDurationSeconds,
                  localizations: _localizations,
                ))),
                Text(_localizations.redeemRequestExplanationItem4),
                Text(_localizations.redeemRequestExplanationItem5,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}
