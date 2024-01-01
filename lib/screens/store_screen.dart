import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/models/store_notice.dart';
import 'package:carol/providers/active_drawer_item_provider.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/screens/issue_stamp_card_dialog_screen.dart';
import 'package:carol/screens/owner_design_blueprint_screen.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class StoreScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<EntityStateNotifier<Store>, Store> storeProvider;
  const StoreScreen({
    super.key,
    required this.storeProvider,
  });

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  final List<StampCardBlueprint> _blueprints = [];
  bool _blueprintsInitLoaded = false;
  // final List<StoreNotice> _storeNotices = [];
  // bool _storeNoticesInitLoaded = false;
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

    final store = ref.read(widget.storeProvider);
    if (store.blueprints != null) {
      // Already fetched. No need to load blueprints
      setState(() {
        _blueprints.addAll(store.blueprints!);
        _blueprintsInitLoaded = true;
      });
      return;
    }

    final storeNotifier = ref.read(widget.storeProvider.notifier);

    loadBlueprints(
      numBps: 3,
      storeId: store.id,
    ).then((value) {
      setState(() {
        // Bind blueprints to store
        storeNotifier.set(entity: store.copyWith(blueprints: value));
        _blueprints.addAll(value);
        _blueprintsInitLoaded = true;
      });
    });
    // loadNotices(
    //   numNotices: 5,
    //   storeId: store.id,
    // ).then((value) {
    //   setState(() {
    //     storeNotifier.set(entity: store.copyWith(notices: value));
    //     _storeNotices.addAll(value);
    //     _storeNoticesInitLoaded = true;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(widget.storeProvider);
    // final watchedBlueprints = _blueprints.map((blueprint) {
    //   return ref.watch(blueprintProviders.tryGetProvider(entity: blueprint)!);
    // }).toList();
    final watchedBlueprints = store.blueprints == null
        ? <StampCardBlueprint>[]
        : store.blueprints!
            .map((blueprint) => ref
                .watch(blueprintProviders.tryGetProvider(entity: blueprint)!))
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
      padding: Utils.basicWidgetEdgeInsets(),
      child: const Text('Here comes google map. (Click to open external app)'),
    );
    final phone = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: Utils.basicWidgetEdgeInsets(),
          child: const Icon(Icons.phone),
        ),
        Padding(
          padding: Utils.basicWidgetEdgeInsets(),
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
          padding: Utils.basicWidgetEdgeInsets(),
          child: const Icon(Icons.home),
        ),
        Padding(
          padding: Utils.basicWidgetEdgeInsets(),
          child: Text(
            store.address,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
    final Widget description = Padding(
      padding: Utils.basicWidgetEdgeInsets(),
      child: Text(store.description),
    );
    final storeName = Padding(
      padding: Utils.basicWidgetEdgeInsets(),
      child: Text(
        store.displayName,
        style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
    final bpsListTitle = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Stamp Cards being Published',
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
    final bpsExplorer = Column(
      children: [
        Padding(
          padding: Utils.basicWidgetEdgeInsets(),
          child: bpsListTitle,
        ),
        !_blueprintsInitLoaded
            ? Padding(
                padding: Utils.basicWidgetEdgeInsets(5),
                child: const CircularProgressIndicator(),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: watchedBlueprints.length,
                itemBuilder: (ctx, index) {
                  final blueprint = watchedBlueprints[index];
                  return ListTile(
                    leading: Icon(
                      blueprint.icon,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    title: Text(
                      blueprint.displayName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (ctx) {
                          return IssueStampCardDialogScreen(
                            blueprintProvider:
                                blueprintProviders.providers[blueprint.id]!,
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
        bpsExplorer,
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
            padding: Utils.basicWidgetEdgeInsets(),
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
            margin: Utils.basicScreenEdgeInsets(ctx, constraints, 0),
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

  Future<List<StampCardBlueprint>> loadBlueprints({
    required int numBps,
    required String storeId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return genDummyBlueprints(
      numBps: numBps,
      storeId: storeId,
    );
  }

  Future<List<StoreNotice>> loadNotices({
    required int numNotices,
    required String storeId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return genDummyNotices(
      numNotices: 5,
      storeId: storeId,
    );
  }

  void _onPressModifyStore() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return OwnerDesignStoreScreen(
          designMode: StoreDesignMode.modify,
          store: ref.read(widget.storeProvider),
        );
      },
    ));
  }

  void _onPressNewBlueprint() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return OwnerDesignBlueprintScreen(
          designMode: BlueprintDesignMode.create,
          storeProvider: widget.storeProvider,
        );
      },
    ));
  }

  // void _onPressNewNotice() {}
}

enum StoreScreenMode {
  customer,
  owner,
}
