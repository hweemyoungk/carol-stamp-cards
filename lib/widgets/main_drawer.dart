import 'package:carol/data/dummy_data.dart';
import 'package:carol/providers/active_drawer_item_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/providers/stores_init_loaded_provider.dart';
import 'package:carol/providers/stores_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: currentUser.profileImageUrl == null
          ? Image.memory(
              kTransparentImage,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            )
          : Image.asset(
              currentUser.profileImageUrl!,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
    );
    final profileIcon = Padding(
      padding: Utils.basicWidgetEdgeInsets(),
      child: avatar,
    );
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                profileIcon,
                Padding(
                  padding: Utils.basicWidgetEdgeInsets(),
                  child: Text(
                    currentUser.displayName,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DrawerItem(
                      text: 'Customer',
                      drawerItemEnum: DrawerItemEnum.customer),
                  DrawerItem(
                    text: 'Owner',
                    drawerItemEnum: DrawerItemEnum.owner,
                  ),
                  DrawerItem(
                    text: 'Settings',
                    drawerItemEnum: DrawerItemEnum.settings,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DrawerItem(
                    text: 'Terms of Use',
                    drawerItemEnum: DrawerItemEnum.termsOfUse,
                  ),
                  DrawerItem(
                    text: 'Privacy Policy',
                    drawerItemEnum: DrawerItemEnum.privacyPolicy,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends ConsumerStatefulWidget {
  const DrawerItem({
    super.key,
    required this.text,
    required this.drawerItemEnum,
  });
  final String text;
  final DrawerItemEnum drawerItemEnum;

  @override
  ConsumerState<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends ConsumerState<DrawerItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(activeDrawerItemProvider.notifier).set(widget.drawerItemEnum);
        _initLoadEntities();
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: Utils.basicWidgetEdgeInsets(),
        child: Text(
          widget.text,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }

  Future<void> _initLoadEntities() async {
    if (widget.drawerItemEnum == DrawerItemEnum.owner &&
        ref.read(ownerStoresInitLoadedProvider) == false) {
      _loadOwnerStores();
    }
  }

  Future<void> _loadOwnerStores() async {
    final storesInitLoadedNotifier =
        ref.read(ownerStoresInitLoadedProvider.notifier);
    final storesNotifier = ref.read(ownerStoresProvider.notifier);
    // Initial load
    if (ownerStoreProviders.providers.isNotEmpty) {
      final loadedStores =
          ownerStoreProviders.providers.entries.map((e) => ref.read(e.value));
      storesNotifier.appendAll(loadedStores);
      storesInitLoadedNotifier.set(true);
    } else {
      // apis.listOwnerStores(ownerId: currentUser.id,);

      // Dummy: Top down
      await Utils.delaySeconds(2);
      // Stores
      final stores = genDummyOwnerStores(
        numStores: 2,
        ownerId: currentUser.id,
      );
      // Blueprints
      stores.forEach((store) {
        final blueprints = genDummyBlueprints(
          numBlueprints: 2,
          storeId: store.id,
        );
      });
      storesNotifier.appendAll(stores);
      storesInitLoadedNotifier.set(true);
    }
  }
}

enum DrawerItemEnum {
  customer,
  owner,
  settings,
  termsOfUse,
  privacyPolicy,
  ;
}
