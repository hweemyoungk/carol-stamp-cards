import 'package:carol/models/store.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoresListItem extends ConsumerStatefulWidget {
  final StateNotifierProvider<StoreNotifier, Store> storeProvider;
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
      onTap: () {},
      leading: Icon(store.icon),
      title: Text(store.displayName),
      trailing: Text(store.getDistanceString(0.0, 0.0)),
    );
  }
}
