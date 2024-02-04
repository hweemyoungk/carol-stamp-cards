import 'package:carol/models/store.dart';
import 'package:carol/providers/stores_notifier.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ownerStoresListStoresProvider =
    StateNotifierProvider<StoresNotifier, List<Store>?>(
        (ref) => StoresNotifier(null));
final customerStoresListStoresProvider =
    StateNotifierProvider<StoresNotifier, List<Store>?>(
        (ref) => StoresNotifier(null));

class StoresList extends ConsumerStatefulWidget {
  const StoresList({super.key});

  @override
  ConsumerState<StoresList> createState() => _StoresListState();
}

class _StoresListState extends ConsumerState<StoresList> {
  late StateNotifierProvider<StoresNotifier, List<Store>?> _storesProvider;
  @override
  void initState() {
    super.initState();

    final activeDrawerItemEnum = ref.read(activeDrawerItemProvider);
    if (activeDrawerItemEnum == DrawerItemEnum.customer) {
      _storesProvider = customerStoresListStoresProvider;
    } else if (activeDrawerItemEnum == DrawerItemEnum.owner) {
      _storesProvider = ownerStoresListStoresProvider;
    } else {
      throw Exception(
          'StoresList can only be reached from customer or owner drawer item');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stores = ref.watch(_storesProvider);

    return stores == null
        ? const CircularProgressIndicator()
        : Expanded(
            child: ListView.builder(
              itemCount: stores.length,
              itemBuilder: (ctx, index) {
                return StoresListItem(
                  key: ValueKey(stores[index].id),
                  store: stores[index],
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
