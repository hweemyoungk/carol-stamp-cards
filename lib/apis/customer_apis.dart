import 'dart:convert';

import 'package:carol/apis/utils.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/params.dart' as params;
import 'package:carol/params.dart';
import 'package:carol/providers/stamp_cards_init_loaded_provider.dart';
import 'package:carol/providers/stamp_cards_provider.dart';
import 'package:carol/providers/stores_init_loaded_provider.dart';
import 'package:carol/providers/stores_provider.dart';

Future<void> reloadCustomerEntities({
  required StampCardsInitLoadedNotifier stampCardsInitLoadedNotifier,
  required StampCardsNotifier stampCardsNotifier,
  required StoresInitLoadedNotifier customerStoresInitLoadedNotifier,
  required StoresNotifier customerStoresNotifier,
}) async {
  // Cards
  final stampCards = await listStampCards(
    customerId: currentUser.id,
  );
  stampCardsNotifier.set(stampCards.toList());
  stampCardsInitLoadedNotifier.set(true);

  // Blueprints
  final blueprints = await listBlueprints(
    blueprintIds: stampCards.map((e) => e.blueprintId).toSet(),
  );
  // Stores
  final stores = await listStores(
    storeIds: blueprints.map((e) => e.storeId).toSet(),
  );

  // Bind blueprints to stores
  final storeMap = stores.fold(<String, Store>{}, (previousValue, store) {
    store.blueprints = [];
    previousValue[store.id] = store;
    return previousValue;
  });
  for (final blueprint in blueprints) {
    storeMap[blueprint.storeId]!.blueprints!.add(blueprint);
  }

  customerStoresNotifier.set(stores.toList());
  customerStoresInitLoadedNotifier.set(true);
}

Future<Set<StampCard>> listStampCards({
  String? customerId,
  Set<String>? stampCardIds,
}) async {
  if (customerId == null && (stampCardIds == null || stampCardIds.isEmpty)) {
    return {};
  }

  // TODO: http
  final url = Uri.http(
    params.apigateway,
    '/customer/api/v1/stampCard/list',
    {
      if (customerId != null) 'userId': customerId,
      if (stampCardIds != null && stampCardIds.isNotEmpty)
        'ids': stampCardIds.toList(),
    },
  );
  final res = await httpGet(url); // Can throw e

  List<Map<String, dynamic>> resBody = json.decode(res.body);
  Set<StampCard> stampCards = {};
  for (final map in resBody) {
    final stampCard = StampCard.fromJson(map);
    stampCards.add(stampCard);
  }
  return stampCards;
}

Future<Set<StampCardBlueprint>> listBlueprints({
  String? storeId,
  Set<String>? blueprintIds,
}) async {
  if (storeId == null && (blueprintIds == null || blueprintIds.isEmpty)) {
    return {};
  }

  // TODO: http
  final url = Uri.http(
    params.apigateway,
    '/customer/api/v1/blueprint/list',
    {
      if (storeId != null) 'storeId': storeId,
      if (blueprintIds != null && blueprintIds.isNotEmpty)
        'ids': blueprintIds.toList(),
    },
  );
  final res = await httpGet(url); // Can throw e

  List<Map<String, dynamic>> resBody = json.decode(res.body);
  Set<StampCardBlueprint> blueprints = {};
  for (final map in resBody) {
    final blueprint = StampCardBlueprint.fromJson(map);
    blueprints.add(blueprint);
  }
  return blueprints;
}

Future<Set<Store>> listStores({
  // String? ownerId, // Owner service only
  Set<String>? storeIds,
}) async {
  if (storeIds == null || storeIds.isEmpty) {
    return {};
  }

  // TODO: http
  final url = Uri.http(
    params.apigateway,
    '/customer/api/v1/store/list',
    {
      'ids': storeIds.toList(),
    },
  );
  final res = await httpGet(url); // Can throw e

  List<Map<String, dynamic>> resBody = json.decode(res.body);
  Set<Store> stores = {};
  for (final json in resBody) {
    final store = Store.fromJson(json);
    stores.add(store);
  }
  return stores;
}

/* Future<(Set<StampCard>, Set<StampCardBlueprint>)> listStampCardsWithBlueprint({
  required String customerId,
}) async {
  // TODO: http
  final url = Uri.http(
    params.apigateway,
    '/customer/api/v1/stampCard',
    {
      'customerId': customerId,
      'withBlueprint': true,
    },
  );
  final res = await http.get(url);
  if (400 <= res.statusCode) {
    throw HttpException('${res.statusCode} ${res.reasonPhrase}: ${res.body}');
  }

  List<Map<String, dynamic>> resBody = json.decode(res.body);
  Set<StampCardBlueprint> blueprints = {};
  Set<StampCard> stampCards = {};
  for (final map in resBody) {
    final blueprint = StampCardBlueprint.fromJson(map['blueprint']);
    blueprints.add(blueprint);
    map['blueprintId'] = blueprint.id;
    final stampCard = StampCard.fromJson(map);
    stampCards.add(stampCard);
  }
  return (stampCards, blueprints);
} */

