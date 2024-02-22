import 'dart:convert';

import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/params/app.dart';
import 'package:carol/providers/blueprint_notifier.dart';
import 'package:carol/providers/store_notifier.dart';
import 'package:carol/screens/blueprint_dialog_screen.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/screens/owner_design_blueprint_screen.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

final customerStoreScreenStoreProvider =
    StateNotifierProvider<StoreNotifier, Store?>((ref) => StoreNotifier(null));
final ownerStoreScreenStoreProvider =
    StateNotifierProvider<StoreNotifier, Store?>((ref) => StoreNotifier(null));

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({
    super.key,
  });

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  late StoreScreenMode _mode;
  late StateNotifierProvider<StoreNotifier, Store?> _storeProvider;

  bool _isClosingStore = false;
  bool _isRefreshCooling = false;

  @override
  void initState() {
    super.initState();
    final activeDrawerItemEnum = ref.read(activeDrawerItemProvider);
    if (activeDrawerItemEnum == DrawerItemEnum.customer) {
      _mode = StoreScreenMode.customer;
      _storeProvider = customerStoreScreenStoreProvider;
    } else if (activeDrawerItemEnum == DrawerItemEnum.owner) {
      _mode = StoreScreenMode.owner;
      _storeProvider = ownerStoreScreenStoreProvider;
    } else {
      throw Exception(
          'StoreScreen can only be reached from customer or owner drawer item');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(_storeProvider);
    if (store == null) {
      return const Loading(message: 'Loading Store...');
    }

    final blueprints = store.blueprints?.toList();
    if (blueprints == null) {
      return const Loading(message: 'Loading Blueprints...');
    }

    final onSecondary = Theme.of(context).colorScheme.onSecondary;

    final hasNotices = store.isClosed;
    final notices = Container(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: DesignUtils.basicWidgetEdgeInsets(),
        child: Column(
          children: [
            if (store.isClosed)
              Row(
                children: [
                  Icon(Icons.warning,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Store was already CLOSED.',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    // Filter blueprints
    final blueprintsToDisplay = _mode == StoreScreenMode.owner
        ? blueprints
        : blueprints
            .where(
              (blueprint) => blueprint.isPublishing,
            )
            .toList();

    final bgImage = store.bgImageUrl == null
        ? Stack(
            children: [
              Image.memory(
                kTransparentImage,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'No Image',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: onSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          )
        : FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            // image: NetworkImage(store.imageUrl!),
            image: AssetImage(store.bgImageUrl!),
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
          );

    // final Widget googleMap = Padding(
    //   padding: DesignUtils.basicWidgetEdgeInsets(),
    //   child: const Text('Here comes google map. (Click to open external app)'),
    // );

    final phone = store.phone == null
        ? null
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(),
                child: const Icon(Icons.phone),
              ),
              Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(),
                child: Text(
                  store.phone!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          );

    final zipcode = store.zipcode == null
        ? null
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(),
                child: const Icon(Icons.location_on),
              ),
              Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(),
                child: Text(
                  store.zipcode!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          );

    final address = store.address == null
        ? null
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(),
                child: const Icon(Icons.home),
              ),
              Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(),
                child: Text(
                  store.address!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          );

    final Widget description = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: Text(store.description),
    );

    final storeName = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: Text(
        store.displayName,
        style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(color: onSecondary),
      ),
    );

    final blueprintsListTitle = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Cards being Published',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: onSecondary,
              ),
          textAlign: TextAlign.left,
        ),
        if (_mode == StoreScreenMode.owner && !store.isClosed)
          IconButton(
            onPressed: _onPressNewBlueprint,
            icon: const Icon(Icons.add_box),
          ),
      ],
    );

    final blueprintsExplorer = Column(
      children: [
        Padding(
          padding: DesignUtils.basicWidgetEdgeInsets(),
          child: blueprintsListTitle,
        ),
        blueprintsToDisplay.isEmpty
            ? Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(),
                child: const Text('No publishing cards!'),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: blueprintsToDisplay.length,
                itemBuilder: (ctx, index) {
                  final blueprint = blueprintsToDisplay[index];
                  return ListTile(
                    title: Text(
                      blueprint.displayName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: blueprint.isPublishing
                        ? null
                        : Icon(
                            Icons.visibility_off,
                            color: onSecondary,
                          ),
                    onTap: () async {
                      _notifyBlueprintDialogScreen(blueprint);
                      await showDialog(
                        context: context,
                        builder: (ctx) {
                          return BlueprintDialogScreen(
                            blueprintDialogMode:
                                _mode == StoreScreenMode.customer
                                    ? BlueprintDialogMode.customer
                                    : BlueprintDialogMode.owner,
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ],
    );

    // Skip Notice now
    // final noticesListTitle = Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Text(
    //       'Notices',
    //       style: Theme.of(context).textTheme.titleLarge!.copyWith(
    //             color: onSecondary,
    //           ),
    //       textAlign: TextAlign.left,
    //     ),
    //     if (_mode == StoreScreenMode.owner)
    //       IconButton(
    //         onPressed: _onPressNewNotice,
    //         icon: const Icon(Icons.add_box),
    //       ),
    //   ],
    // );
    // final noticesExplorer = Column(
    //   children: [
    //     Padding(
    //       padding: Utils.basicWidgetEdgeInsets(),
    //       child: noticesListTitle,
    //     ),
    //     !_storeNoticesInitLoaded
    //         ? Padding(
    //             padding: Utils.basicWidgetEdgeInsets(5),
    //             child: const CircularProgressIndicator(),
    //           )
    //         : ListView.builder(
    //             shrinkWrap: true,
    //             physics: const NeverScrollableScrollPhysics(),
    //             itemCount: _storeNotices.length,
    //             itemBuilder: (ctx, index) {
    //               final notice = _storeNotices[index];
    //               return ListTile(
    //                 leading: Icon(
    //                   notice.icon,
    //                   color: onSecondary,
    //                 ),
    //                 title: Text(
    //                   notice.displayName,
    //                   style: Theme.of(context).textTheme.bodyLarge,
    //                 ),
    //               );
    //             },
    //           ),
    //   ],
    // );
    final qrCodeButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        disabledBackgroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: _onPressQrCode,
      icon: Icon(
        Icons.qr_code,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      label: Text(
        'Show Store QR',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
    final closeStoreButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        disabledBackgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
      onPressed: _isClosingStore ? null : _onPressCloseStore,
      icon: Icon(
        Icons.delete,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
      label: _isClosingStore
          ? CircularProgressIndicatorInButton(
              color: Theme.of(context).colorScheme.onErrorContainer)
          : Text(
              'Close Store',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
    );
    final mainContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        storeName,
        if (zipcode != null) zipcode,
        if (address != null) address,
        if (phone != null) phone,
        // googleMap,
        blueprintsExplorer,
        description,
        // noticesExplorer,
        if (!store.isInactive) qrCodeButton,
        if (_mode == StoreScreenMode.owner && !store.isClosed) closeStoreButton,
      ],
    );
    final contentOnBgImage = SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (hasNotices) notices,
          Image.memory(
            kTransparentImage,
            height: 300,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Container(
            color: Theme.of(context).colorScheme.secondary,
            padding: DesignUtils.basicWidgetEdgeInsets(),
            child: mainContent,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_mode == StoreScreenMode.owner && !store.isClosed)
            IconButton(
              onPressed: _onPressModifyStore,
              icon: const Icon(Icons.construction),
            ),
          _isRefreshCooling
              ? const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.refresh),
                )
              : IconButton(
                  onPressed: _onPressRefreshStore,
                  icon: const Icon(Icons.refresh),
                ),
        ],
      ),
      // appBar: _mode == StoreScreenMode.customer
      //     ? null
      //     : AppBar(
      //         actions: [
      //           IconButton(
      //               onPressed: _onPressModifyStore,
      //               icon: const Icon(Icons.construction))
      //         ],
      //       ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          return Container(
            alignment: Alignment.center,
            margin: DesignUtils.basicScreenEdgeInsets(ctx, constraints, 0),
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: [
                  bgImage,
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: contentOnBgImage,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Notifies either <code>customerBlueprintDialogScreenBlueprintProvider</code> or <code>ownerBlueprintDialogScreenBlueprintProvider</code>.
  void _notifyBlueprintDialogScreen(Blueprint blueprint) {
    final activeDrawerItem = ref.read(activeDrawerItemProvider);
    final StateNotifierProvider<BlueprintNotifier, Blueprint?>
        blueprintProvider;
    if (activeDrawerItem == DrawerItemEnum.customer) {
      blueprintProvider = customerBlueprintDialogScreenBlueprintProvider;
    } else if (activeDrawerItem == DrawerItemEnum.owner) {
      blueprintProvider = ownerBlueprintDialogScreenBlueprintProvider;
      // Attach store to blueprint
      final store = ref.read(_storeProvider);
      blueprint = blueprint.copyWith(store: store);
    } else {
      Carol.showTextSnackBar(
        text: 'Can only be reached from customer or owner drawer item',
        level: SnackBarLevel.error,
      );
      return;
    }
    final blueprintNotifier = ref.read(blueprintProvider.notifier);
    blueprintNotifier.set(null);
    blueprintNotifier.set(blueprint);
  }

  void _onPressModifyStore() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return OwnerDesignStoreScreen(
          designMode: StoreDesignMode.modify,
          store: ref.read(ownerStoreScreenStoreProvider),
        );
      },
    ));
  }

  void _onPressNewBlueprint() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const OwnerDesignBlueprintScreen(
          designMode: BlueprintDesignMode.create,
        );
      },
    ));
  }

  void _onPressCloseStore() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        'Close this store?',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                      Text(
                        '(cannot undo)',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Text(
                'Closed store will be deleted in $deleteClosedStoreInDays days automatically.'),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.background),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                      ),
                      onPressed: _closeStore,
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      )),
                ],
              ),
            ),
          ],
        );
      },
      useSafeArea: true,
    );
  }

  Future<void> _closeStore() async {
    final storeNotifier = ref.read(_storeProvider.notifier);

    Navigator.of(context).pop();

    setState(() {
      _isClosingStore = true;
    });

    final store = ref.read(_storeProvider);
    if (store == null) return;

    // Close Store
    try {
      await owner_apis.closeStore(id: store.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to delete card.',
      );
      return;
    }

    final closedStore = store.copyWith(
      isClosed: true,
      isInactive: true,
    );

    // Propagate
    // ownerStoresListStoresProvider
    final storesNotifier = ref.read(ownerStoresListStoresProvider.notifier);
    storesNotifier.replaceOrPrepend(closedStore);
    // ownerStoreScreenStoreProvider
    storeNotifier.set(closedStore);

    Carol.showTextSnackBar(
      text: 'Closed store!',
      level: SnackBarLevel.success,
    );

    setState(() {
      _isClosingStore = false;
    });
  }

  /// Fetched store must have <i>non-null<i> blueprints.
  Future<void> _onPressRefreshStore() async {
    _setRefreshCooling();

    final store = ref.read(_storeProvider);
    final storeNotifier = ref.read(_storeProvider.notifier);
    if (store == null) return;

    final Store storeWithBlueprints;

    final Store fetchedStore;
    final Set<Blueprint> fetchedBlueprints;
    if (_mode == StoreScreenMode.customer) {
      // Customer mode
      try {
        // [
        //   fetchedStore as Store,
        //   fetchedBlueprints as Set<Blueprint>,
        // ] = await Future.wait([
        //   customer_apis.getStore(id: store.id),
        //   customer_apis.listBlueprints(storeId: store.id),
        // ]);
        fetchedStore = await customer_apis.getStore(id: store.id);
        fetchedBlueprints =
            await customer_apis.listBlueprints(storeId: store.id);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get store information.',
        );
        return;
      }
      storeWithBlueprints =
          fetchedStore.copyWith(blueprints: fetchedBlueprints);

      // Propagate
      // customerStoresListStoresProvider
      final storesNotifier =
          ref.read(customerStoresListStoresProvider.notifier);
      storesNotifier.replaceOrPrepend(storeWithBlueprints);
      // customerCardsListCardsProvider,customerCardScreenCardProvider
      final cardsNotifier = ref.read(customerCardsListCardsProvider.notifier);
      final cardNotifier = ref.read(customerCardScreenCardProvider.notifier);
      final card = ref.read(customerCardScreenCardProvider);
      if (card?.blueprint != null) {
        final modifiedCard = card!.copyWith(
          blueprint: card.blueprint!.copyWith(
            store: storeWithBlueprints,
          ),
        );
        cardNotifier.set(modifiedCard);
        cardsNotifier.replaceOrPrepend(modifiedCard);
      }
    } else {
      // Owner mode
      try {
        [
          fetchedStore as Store,
          fetchedBlueprints as Set<Blueprint>,
        ] = await Future.wait([
          owner_apis.getStore(id: store.id),
          owner_apis.listBlueprints(storeId: store.id),
        ]);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get store information.',
        );
        return;
      }
      storeWithBlueprints =
          fetchedStore.copyWith(blueprints: fetchedBlueprints);
      // Propagate
      // ownerStoresListStoresProvider
      final storesNotifier = ref.read(ownerStoresListStoresProvider.notifier);
      storesNotifier.replaceOrPrepend(storeWithBlueprints);
    }

    storeNotifier.set(storeWithBlueprints);
    Carol.showTextSnackBar(
      text: 'Refreshed store!',
      level: SnackBarLevel.info,
    );
  }

  Future<void> _setRefreshCooling() async {
    if (!mounted) return;
    setState(() {
      _isRefreshCooling = true;
    });
    await Future.delayed(refreshCoolingDuration);
    if (!mounted) return;
    setState(() {
      _isRefreshCooling = false;
    });
  }

  void _onPressQrCode() {
    final store = ref.read(_storeProvider);
    if (store == null) return;

    final qrImageView = QrImageView(
      data: base64.encode(
          json.encode(SimpleStoreQr.fromStore(store).toJson()).codeUnits),
      version: QrVersions.auto,
      // size: constraints.maxWidth * 0.4,
      size: 150,
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Store QR'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: qrImageView,
              ),
              const Text('Let customers scan!')
            ],
          ),
        );
      },
    );
  }
}

enum StoreScreenMode {
  customer,
  owner,
}
