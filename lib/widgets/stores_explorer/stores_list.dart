import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/widgets/common/load_more_button.dart';
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
  bool _initLoaded = false;

  @override
  void initState() {
    super.initState();
    if (StoreProviders.providers.isNotEmpty) {
      _initLoaded = true;
      for (final entry in StoreProviders.providers.entries) {
        final store = ref.read(entry.value);
        _stores.add(store);
      }
    } else {
      loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_initLoaded
        ? CircularProgressIndicator()
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
                            StoreProviders.providers[_stores[index].id]!,
                      );
              },
            ),
          );
  }

  Future<void> loadMore() async {
    try {
      final value = await loadStores(numStores: 10);
      if (mounted) {
        setState(() {
          _stores.addAll(value);
          _initLoaded = true;
        });
      }
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<List<Store>> loadStores({required int numStores}) async {
    await Future.delayed(const Duration(seconds: 1));
    return genDummyStores(numStores: numStores);
  }

  Future<void> _onPressLoadMore() async {
    await loadMore();
  }
}
