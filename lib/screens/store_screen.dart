import 'package:carol/models/store.dart';
import 'package:carol/providers/store_notifier.dart';
import 'package:carol/screens/blueprint_dialog_screen.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/screens/owner_design_blueprint_screen.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

// Watch customerCardScreenCardProvider instead
// final customerStoreScreenStoreProvider = StateNotifierProvider<StoreNotifier, Store?>((ref) => StoreNotifier(null));
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

  @override
  void initState() {
    super.initState();
    final activeDrawerItemEnum = ref.read(activeDrawerItemProvider);
    if (activeDrawerItemEnum == DrawerItemEnum.customer) {
      _mode = StoreScreenMode.customer;
    } else if (activeDrawerItemEnum == DrawerItemEnum.owner) {
      _mode = StoreScreenMode.owner;
    } else {
      throw Exception(
          'StoreScreen can only be reached from customer or owner drawer item');
    }
  }

  Store? _watchStore() {
    if (_mode == StoreScreenMode.customer) {
      final card = ref.watch(customerCardScreenCardProvider);
      return card?.blueprint?.store;
    }
    return ref.watch(ownerStoreScreenStoreProvider);
  }

  @override
  Widget build(BuildContext context) {
    final store = _watchStore();
    if (store == null) {
      return const Loading(message: 'Loading Store...');
    }

    final blueprints = store.blueprints?.toList();
    if (blueprints == null) {
      return const Loading(message: 'Loading Blueprints...');
    }

    // Filter blueprints
    final blueprintsToDisplay = _mode == StoreScreenMode.owner
        ? blueprints
        : blueprints
            .where(
              (blueprint) => blueprint.isPublishing,
            )
            .toList();

    final bgImage = store.bgImageUrl == null
        ? Image.memory(
            kTransparentImage,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          )
        : FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            // image: NetworkImage(store.imageUrl!),
            image: AssetImage(store.bgImageUrl!),
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
          );

    final Widget googleMap = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: const Text('Here comes google map. (Click to open external app)'),
    );

    final phone = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: DesignUtils.basicWidgetEdgeInsets(),
          child: const Icon(Icons.phone),
        ),
        Padding(
          padding: DesignUtils.basicWidgetEdgeInsets(),
          child: Text(
            store.phone,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );

    final address = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: DesignUtils.basicWidgetEdgeInsets(),
          child: const Icon(Icons.home),
        ),
        Padding(
          padding: DesignUtils.basicWidgetEdgeInsets(),
          child: Text(
            store.address,
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
            .copyWith(color: Theme.of(context).colorScheme.onSecondary),
      ),
    );

    final blueprintsListTitle = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Cards being Published',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
          textAlign: TextAlign.left,
        ),
        if (_mode == StoreScreenMode.owner)
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
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    onTap: () async {
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
    //             color: Theme.of(context).colorScheme.onSecondary,
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
    //                   color: Theme.of(context).colorScheme.onSecondary,
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
    final mainContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        storeName,
        address,
        phone,
        googleMap,
        blueprintsExplorer,
        description,
        // noticesExplorer,
      ],
    );
    final contentOnBgImage = SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
      appBar: _mode == StoreScreenMode.customer
          ? null
          : AppBar(
              actions: [
                IconButton(
                    onPressed: _onPressModifyStore,
                    icon: const Icon(Icons.construction))
              ],
            ),
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
}

enum StoreScreenMode {
  customer,
  owner,
}
