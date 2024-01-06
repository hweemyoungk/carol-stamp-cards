import 'package:carol/providers/stamp_cards_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/providers/stores_init_loaded_provider.dart';
import 'package:carol/providers/stores_provider.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_explorer.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Scaffold(
      body: widget.customerScreenBodies[_activeBottomItemIndex],
      appBar: AppBar(
        title: const Text('Customer\'s Screen'),
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
    if (value == 1) {
      final storesInitLoaded = ref.read(customerStoresInitLoadedProvider);
      if (!storesInitLoaded) {
        // Load Customer Stores
        _loadCustomerStores();
      }
    }
    if (mounted) {
      setState(() {
        _activeBottomItemIndex = value;
      });
    }
  }

  Future<void> _loadCustomerStores() async {
    final storesInitLoadedNotifier =
        ref.read(customerStoresInitLoadedProvider.notifier);
    // Initial load
    if (customerStoreProviders.providers.isNotEmpty) {
      final loadedStores = customerStoreProviders.providers.entries
          .map((e) => ref.read(e.value));
      ref.read(customerStoresProvider.notifier).appendAll(loadedStores);
      storesInitLoadedNotifier.set(true);
    } else {
      // apis.listCustomerStores(customerId: currentUser.id,);
      // Get storeIds from stampCards
      final stampCards = ref.read(stampCardsProvider);
      final storeIdsSet = stampCards.map((e) => e.storeId).toSet();
      final stores = storeIdsSet.map((storeId) =>
          ref.read(customerStoreProviders.tryGetProviderById(id: storeId)!));
      ref.read(customerStoresProvider.notifier).appendAll(stores);
      storesInitLoadedNotifier.set(true);

      await Utils.delaySeconds(2);
    }
  }
}
