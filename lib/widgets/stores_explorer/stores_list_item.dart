import 'package:carol/models/store.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoresListItem extends ConsumerStatefulWidget {
  final StateNotifierProvider<EntityStateNotifier<Store>, Store> storeProvider;
  const StoresListItem({
    super.key,
    required this.storeProvider,
  });

  @override
  ConsumerState<StoresListItem> createState() => _StoresListItemState();
}

class _StoresListItemState extends ConsumerState<StoresListItem> {
  @override
  Widget build(BuildContext context) {
    final store = ref.watch(widget.storeProvider);
    return ListTile(
      onTap: _onTapItem,
      title: Text(store.displayName),
      trailing: Text(store.getDistanceString(0.0, 0.0)),
    );
  }

  void _onTapItem() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return StoreScreen(
          storeProvider: widget.storeProvider,
        );
      },
    ));
  }
}
