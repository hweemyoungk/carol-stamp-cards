import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/screens/scan_qr_screen.dart';
import 'package:carol/widgets/cards_explorer/cards_explorer.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/common/icon_button_in_progress.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool isCustomerModelsInitLoaded(WidgetRef ref) {
  final cardsLoaded = ref.read(customerCardsListCardsProvider) != null;
  final storesLoaded = ref.read(customerStoresListStoresProvider) != null;
  return cardsLoaded && storesLoaded;
}

bool watchCustomerModelsInitLoaded(WidgetRef ref) {
  final cardsLoaded = ref.watch(customerCardsListCardsProvider) != null;
  final storesLoaded = ref.watch(customerStoresListStoresProvider) != null;
  return cardsLoaded && storesLoaded;
}

class CustomerScreen extends ConsumerStatefulWidget {
  CustomerScreen({super.key});

  final customerScreenBodies = {
    0: const CardsExplorer(),
    1: const StoresExplorer(),
  };

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  int _activeBottomItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isLoaded = watchCustomerModelsInitLoaded(ref);
    return Scaffold(
      body: widget.customerScreenBodies[_activeBottomItemIndex],
      appBar: AppBar(
        title: const Text('Customer\'s Screen'),
        actions: [
          if (_activeBottomItemIndex == 1)
            IconButton(
              onPressed: _onPressScanQr,
              icon: const Icon(Icons.qr_code_scanner),
            ),
          !isLoaded
              ? const IconButtonInProgress()
              : IconButton(
                  onPressed: _reloadCardsAndStores,
                  icon: const Icon(Icons.refresh),
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeBottomItemIndex,
        onTap: _onTapBottomItem,
        items: const [
          BottomNavigationBarItem(
            label: 'Cards',
            icon: Icon(Icons.card_giftcard),
          ),
          BottomNavigationBarItem(
            label: 'Stores',
            icon: Icon(Icons.store),
          ),
        ],
      ),
      drawer: const MainDrawer(),
    );
  }

  void _onTapBottomItem(value) {
    if (mounted) {
      setState(() {
        _activeBottomItemIndex = value;
      });
    }
  }

  void _reloadCardsAndStores() {
    customer_apis.reloadCustomerModels(ref);
  }

  void _onPressScanQr() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ScanQrScreen(),
    ));
  }
}
