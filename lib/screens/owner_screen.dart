import 'package:carol/apis/owner_apis.dart';
import 'package:carol/main.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/screens/scan_qr_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_explorer.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_list.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  int _activeBottomItemIndex = 0;
  bool _isRefreshStoresCooling = false;
  bool _isRefreshRedeemRequestsCooling = false;
  // bool _isReloadingStores = false;

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Owner\'s Screen'),
        actions: _getAppBarActions(),
      ),
      drawer: const MainDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeBottomItemIndex,
        onTap: _onTapBottomItem,
        items: const [
          BottomNavigationBarItem(
            label: 'Stores',
            icon: Icon(Icons.store),
          ),
          BottomNavigationBarItem(
            label: 'Redeem Requests',
            icon: Icon(Icons.approval),
          ),
        ],
      ),
    );
  }

  void _onPressNewStore() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const OwnerDesignStoreScreen(
        designMode: StoreDesignMode.create,
      ),
    ));
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
          onPressed: _onPressNewStore,
          icon: const Icon(Icons.add),
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
      redeemRequests = await listRedeemRequests(ownerId: currentUser.id);
    } on Exception catch (e) {
      redeemRequestsNotifier.set([]);
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to reload redeem requests.',
      );
      return;
    }
    // Propagate
    // ownerRedeemRequestsListRedeemRequestsProvider
    redeemRequestsNotifier.set(redeemRequests.toList());
  }

  void _onPressRefreshStores() {
    _setRefreshStoresCooling();
    reloadOwnerModels(ref);
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
}
