import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/store_notifier.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
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
    final inactiveColor =
        Theme.of(context).colorScheme.onBackground.withOpacity(0.5);
    final distanceString = store.getDistanceString(0.0, 0.0);
    return ListTile(
      onTap: _onTapItem,
      title: Text(
        store.displayName,
        style: !store.isInactive ? null : TextStyle(color: inactiveColor),
      ),
      trailing: distanceString == null
          ? null
          : Text(
              distanceString,
              style: !store.isInactive ? null : TextStyle(color: inactiveColor),
            ),
    );
  }

  void _onTapItem() {
    _notifyStoreScreen();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return const StoreScreen();
      },
    ));
  }

  Future<void> _notifyStoreScreen() async {
    final activeDrawerItemEnum = ref.read(activeDrawerItemProvider);
    final storesNotifier = ref.read(customerStoresListStoresProvider.notifier);
    final StateNotifierProvider<StoreNotifier, Store?> storeProvider;
    if (activeDrawerItemEnum == DrawerItemEnum.customer) {
      storeProvider = customerStoreScreenStoreProvider;
    } else if (activeDrawerItemEnum == DrawerItemEnum.owner) {
      storeProvider = ownerStoreScreenStoreProvider;
    } else {
      Carol.showTextSnackBar(
        text: 'Can only be reached from customer or owner drawer item',
        level: SnackBarLevel.error,
      );
      return;
    }
    final storeNotifier = ref.read(storeProvider.notifier);
    storeNotifier.set(null);

    // Store needs blueprints
    final store = widget.store;
    if (store.blueprints != null) {
      storeNotifier.set(widget.store);
      return;
    }

    final Set<Blueprint> blueprints;
    try {
      blueprints = await customer_apis.listBlueprints(storeId: store.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to get blueprints information.',
      );
      return;
    }
    final newStore = store.copyWith(blueprints: blueprints);
    // Propagate
    // customerCardsListCardsProvider: Not relevant
    // customerStoresListStoresProvider
    storesNotifier.replaceOrPrepend(newStore);

    storeNotifier.set(newStore);
  }
}
