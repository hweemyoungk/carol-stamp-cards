import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/active_drawer_item_provider.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/providers/stores_init_loaded_provider.dart';
import 'package:carol/providers/stores_provider.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoresList extends ConsumerStatefulWidget {
  const StoresList({super.key});

  @override
  ConsumerState<StoresList> createState() => _StoresListState();
}

class _StoresListState extends ConsumerState<StoresList> {
  final ScrollController _controller = ScrollController();
  // final List<Store> _stores = [];
  late EntityProviders<Store> storeProviders;
  late StateNotifierProvider<StoresNotifier, List<Store>> storesProvider;
  late StateNotifierProvider<StoresInitLoadedNotifier, bool>
      storesInitLoadedProvider;

  late List<Store> Function({int numStores, String? ownerId}) genDummyStores;
  late int numStores;

  @override
  void initState() {
    super.initState();

    final activeDrawerItemEnum = ref.read(activeDrawerItemProvider);
    if (activeDrawerItemEnum == DrawerItemEnum.customer) {
      storeProviders = customerStoreProviders;
      storesProvider = customerStoresProvider;
      storesInitLoadedProvider = customerStoresInitLoadedProvider;
      genDummyStores = genDummyCustomerStores;
      numStores = 10;
    } else if (activeDrawerItemEnum == DrawerItemEnum.owner) {
      storeProviders = ownerStoreProviders;
      storesProvider = ownerStoresProvider;
      storesInitLoadedProvider = ownerStoresInitLoadedProvider;
      genDummyStores = genDummyOwnerStores;
      numStores = 2;
    } else {
      throw Exception(
          'StoresList can only be reached from customer or owner drawer item');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Store> stores = ref.watch(storesProvider);
    final storesInitLoaded = ref.watch(storesInitLoadedProvider);

    return !storesInitLoaded
        ? const CircularProgressIndicator()
        : Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: stores.length,
              itemBuilder: (ctx, index) {
                return StoresListItem(
                  key: ValueKey(stores[index].id),
                  storeProvider: storeProviders.providers[stores[index].id]!,
                );
              },
            ),
          );
  }

  // Skip in phase 1
  // Future<void> loadMore() async {
  //   final storesNotifier = ref.read(storesProvider.notifier);
  //   try {
  //     final value = await loadStores(numStores: numStores);
  //     storesNotifier.appendAll(value);
  //   } on Exception catch (e) {
  //   }
  // }

  // Future<List<Store>> loadStores({required int numStores}) async {
  //   final currentUser = ref.read(currentUserProvider)!;
  //   await Future.delayed(const Duration(seconds: 1));
  //   return genDummyStores(numStores: numStores, ownerId: currentUser.id);
  // }

  // Future<void> _onPressLoadMore() async {
  //   await loadMore();
  // }
}
