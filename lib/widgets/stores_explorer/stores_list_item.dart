import 'package:carol/models/store.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoresListItem extends ConsumerStatefulWidget {
  final Store store;
  const StoresListItem({
    super.key,
    required this.store,
  });

  @override
  ConsumerState<StoresListItem> createState() => _StoresListItemState();
}

class _StoresListItemState extends ConsumerState<StoresListItem> {
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListTile(
      onTap: _onTapItem,
      title: Text(store.displayName),
      trailing: Text(store.getDistanceString(0.0, 0.0)),
    );
  }

  void _onTapItem() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return const StoreScreen();
      },
    ));
  }
}
