import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/current_user_provider.dart';
import 'package:carol/providers/stamp_cards_init_loaded_provider.dart';
import 'package:carol/providers/stamp_cards_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/providers/stores_init_loaded_provider.dart';
import 'package:carol/providers/stores_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> reloadCustomerEntities(WidgetRef ref) async {
  final currentUser = ref.read(currentUserProvider)!;
  final stampCardsInitLoadedNotifier =
      ref.read(stampCardsInitLoadedProvider.notifier);
  final stampCardsNotifier = ref.read(stampCardsProvider.notifier);
  final customerStoresInitLoadedNotifier =
      ref.read(customerStoresInitLoadedProvider.notifier);
  final customerStoresNotifier = ref.read(customerStoresProvider.notifier);

  // Dummy: Top down
  await DesignUtils.delaySeconds(2);
  // Stores
  final stores = genDummyCustomerStores(
    numStores: 2,
    ownerId: currentUser.id,
  );
  // Blueprints
  stores.forEach((store) {
    final storeProvider =
        customerStoreProviders.tryGetProviderById(id: store.id)!;
    final storeNotifier = ref.read(storeProvider.notifier);
    final blueprints = genDummyBlueprints(
      numBlueprints: 2,
      storeId: store.id,
    );
    final storeWithBlueprints = store.copyWith(blueprints: blueprints);
    storeNotifier.set(entity: storeWithBlueprints);
    customerStoresNotifier.append(storeWithBlueprints);

    blueprints.forEach((blueprint) {
      // StampCards
      final stampCards = genDummyStampCards(
        blueprint: blueprint,
        customerId: currentUser.id,
        numCards: 1,
      );
      stampCardsNotifier.appendAll(stampCards);
    });
  });

  customerStoresInitLoadedNotifier.set(true);
  stampCardsInitLoadedNotifier.set(true);
}

Future<List<Store>> loadStores({
  required String userId,
  required int numStores,
  String? ownerId,
}) async {
  await Future.delayed(const Duration(seconds: 1));
  return genDummyStores(numStores: numStores, ownerId: ownerId);
}

Future<void> dummyLoadCardsAndStores(WidgetRef ref) async {
  final currentUser = ref.read(currentUserProvider)!;
  final stampCardsInitLoadedNotifier =
      ref.read(stampCardsInitLoadedProvider.notifier);
  final stampCardsNotifier = ref.read(stampCardsProvider.notifier);

  // Dummy: Top down
  await DesignUtils.delaySeconds(2);
  // Stores
  final stores = genDummyCustomerStores(
    numStores: 2,
    ownerId: currentUser.id,
  );
  // Blueprints
  stores.forEach((store) {
    final storeProvider =
        customerStoreProviders.tryGetProviderById(id: store.id)!;
    final storeNotifier = ref.read(storeProvider.notifier);
    final blueprints = genDummyBlueprints(
      numBlueprints: 2,
      storeId: store.id,
    );
    storeNotifier.set(entity: store.copyWith(blueprints: blueprints));

    blueprints.forEach((blueprint) {
      // StampCards
      final stampCards = genDummyStampCards(
        blueprint: blueprint,
        customerId: currentUser.id,
        numCards: 1,
      );
      stampCardsNotifier.appendAll(stampCards);
    });
  });
  stampCardsInitLoadedNotifier.set(true);
}
