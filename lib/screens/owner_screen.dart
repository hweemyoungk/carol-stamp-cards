import 'package:carol/apis/owner_apis.dart';
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/current_user_provider.dart';
import 'package:carol/providers/redeem_requests_init_loaded_provider.dart';
import 'package:carol/providers/redeem_requests_provider.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/screens/owner_scan_qr_screen.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_explorer.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    Navigator.of(context).push<SimpleStampCardQr>(MaterialPageRoute(
      builder: (context) => const OwnerScanQrScreen(),
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
    if (value == 1) {
      // RedeemRequestExplorer
      final ownerRedeemRequestsInitLoaded =
          ref.read(ownerRedeemRequestsInitLoadedProvider);
      final ownerRedeemRequestsInitLoadedNotifier =
          ref.read(ownerRedeemRequestsInitLoadedProvider.notifier);
      final ownerRedeemRequestsNotifier =
          ref.read(ownerRedeemRequestsProvider.notifier);
      final currentUser = ref.read(currentUserProvider)!;

      if (!ownerRedeemRequestsInitLoaded) {
        reloadOwnerRedeemRequests(
          ownerRedeemRequestsInitLoadedNotifier:
              ownerRedeemRequestsInitLoadedNotifier,
          ownerRedeemRequestsNotifier: ownerRedeemRequestsNotifier,
          ownerId: currentUser.id,
        ).onError<Exception>((error, stackTrace) {
          Carol.showExceptionSnackBar(
            error,
            contextMessage: 'Failed to load redeem requests.',
          );
        });
      }
    }

    if (mounted) {
      setState(() {
        _activeBottomItemIndex = value;
      });
    }
  }

  List<Widget>? _getAppBarActions() {
    if (_activeBottomItemIndex == 0) {
      return [
        IconButton(
          onPressed: _onPressNewStore,
          icon: const Icon(Icons.add),
        ),
      ];
    } else {
      final ownerRedeemRequestsInitLoadedNotifier =
          ref.read(ownerRedeemRequestsInitLoadedProvider.notifier);
      final ownerRedeemRequestsNotifier =
          ref.read(ownerRedeemRequestsProvider.notifier);
      final ownerId = ref.read(currentUserProvider)!.id;
      return [
        IconButton(
          onPressed: () {
            reloadOwnerRedeemRequests(
              ownerRedeemRequestsInitLoadedNotifier:
                  ownerRedeemRequestsInitLoadedNotifier,
              ownerRedeemRequestsNotifier: ownerRedeemRequestsNotifier,
              ownerId: ownerId,
            ).onError<Exception>((error, stackTrace) {
              Carol.showExceptionSnackBar(
                error,
                contextMessage: 'Failed to load redeem requests.',
              );
            });
          },
          icon: const Icon(Icons.refresh),
        ),
      ];
    }
  }
}
