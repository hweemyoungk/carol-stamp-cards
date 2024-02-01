import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/owner_apis.dart';
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/store.dart';
import 'package:carol/params/auth.dart';
import 'package:carol/providers/active_drawer_item_provider.dart';
import 'package:carol/providers/current_user_provider.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/providers/stamp_cards_init_loaded_provider.dart';
import 'package:carol/providers/stamp_cards_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/providers/stores_init_loaded_provider.dart';
import 'package:carol/providers/stores_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider)!;
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
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: avatar,
    );
    return Drawer(
      width: 250,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          DrawerHeader(
            child: TextButton(
              onPressed: _onPressAccount,
              child: Row(
                children: [
                  profileIcon,
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      currentUser.displayName,
                      style:
                          Theme.of(context).textTheme.headlineLarge!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                    ),
                  ),
                ],
              ),
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
                    text: 'Membership',
                    drawerItemEnum: DrawerItemEnum.membership,
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

  Future<void> _onPressAccount() async {
    final url = Uri.http(keycloakHostname, accountPath);
    await launchInBrowserView(url);
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
        padding: DesignUtils.basicWidgetEdgeInsets(),
        child: Text(
          widget.text,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }

  void _initLoadEntities() {
    if (widget.drawerItemEnum == DrawerItemEnum.customer &&
        !(ref.read(stampCardsInitLoadedProvider) &&
            ref.read(customerStoresInitLoadedProvider))) {
      final currentUser = ref.read(currentUserProvider)!;
      final stampCardsInitLoadedNotifier =
          ref.read(stampCardsInitLoadedProvider.notifier);
      final stampCardsNotifier = ref.read(stampCardsProvider.notifier);
      final customerStoresInitLoadedNotifier =
          ref.read(customerStoresInitLoadedProvider.notifier);
      final customerStoresNotifier = ref.read(customerStoresProvider.notifier);
      customer_apis
          .reloadCustomerEntities(
        currentUser: currentUser,
        stampCardsInitLoadedNotifier: stampCardsInitLoadedNotifier,
        stampCardsNotifier: stampCardsNotifier,
        customerStoresInitLoadedNotifier: customerStoresInitLoadedNotifier,
        customerStoresNotifier: customerStoresNotifier,
      )
          .onError(
        (error, stackTrace) {
          if (error is Exception) {
            Carol.showExceptionSnackBar(
              error,
              contextMessage: 'Failed to load customer entities.',
            );
          }
        },
      );
    } else if (widget.drawerItemEnum == DrawerItemEnum.owner &&
        ref.read(ownerStoresInitLoadedProvider) == false) {
      _loadOwnerEntities();
    } else if (widget.drawerItemEnum == DrawerItemEnum.membership) {
      // NOOP: contents are loaded from access token
    }
  }

  Future<void> _loadOwnerEntities() async {
    final currentUser = ref.read(currentUserProvider)!;
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
      final Set<Store> stores;
      try {
        stores = await listStores(ownerId: currentUser.id);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get stores information.',
        );
        return;
      }
      ownerStoreProviders.tryAddProviders(entities: stores);
      for (final store in stores) {
        blueprintProviders.tryAddProviders(entities: store._blueprints ?? []);
      }
      storesNotifier.appendAll(stores);
      storesInitLoadedNotifier.set(true);
    }
  }
}

enum DrawerItemEnum {
  customer,
  owner,
  membership,
  settings,
  termsOfUse,
  privacyPolicy,
  ;
}
