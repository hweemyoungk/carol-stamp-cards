import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/active_drawer_item_provider.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/widgets/common/load_more_button.dart';
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
  final List<Store> _stores = [];
  bool _storesInitLoaded = false;
  late EntityProviders<Store> storeProviders;

  late List<Store> Function({int numStores, String? ownerId}) genDummyStores;
  late int numStores;

  @override
  void initState() {
    super.initState();

    final activeDrawerItemEnum = ref.read(activeDrawerItemProvider);
    if (activeDrawerItemEnum == DrawerItemEnum.customer) {
      storeProviders = customerStoreProviders;
      genDummyStores = genDummyCustomerStores;
      numStores = 10;
    } else if (activeDrawerItemEnum == DrawerItemEnum.owner) {
      storeProviders = ownerStoreProviders;
      genDummyStores = genDummyOwnerStores;
      numStores = 2;
    } else {
      throw Exception(
          'StoresList can only be reached from customer or owner drawer item');
    }

    if (storeProviders.providers.isNotEmpty) {
      for (final entry in storeProviders.providers.entries) {
        final store = ref.read(entry.value);
        _stores.add(store);
      }
      _storesInitLoaded = true;
    } else {
      loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_storesInitLoaded
        ? const CircularProgressIndicator()
        : Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: _stores.length + 1,
              itemBuilder: (ctx, index) {
                return index == _stores.length
                    ? LoadMoreButton(onPressLoadMore: _onPressLoadMore)
                    : StoresListItem(
                        key: ValueKey(_stores[index].id),
                        storeProvider:
                            storeProviders.providers[_stores[index].id]!,
                      );
              },
            ),
          );
  }

  Future<void> loadMore() async {
    try {
      final value = await loadStores(numStores: numStores);
      if (mounted) {
        setState(() {
          _stores.addAll(value);
          _storesInitLoaded = true;
        });
      }
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<List<Store>> loadStores({required int numStores}) async {
    await Future.delayed(const Duration(seconds: 1));
    return genDummyStores(numStores: numStores, ownerId: currentUser.id);
  }

  Future<void> _onPressLoadMore() async {
    await loadMore();
  }
}
