import 'dart:convert';

import 'package:carol/apis/utils.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/models/user.dart';
import 'package:carol/params/backend.dart' as backend_params;
import 'package:carol/providers/redeem_rule_provider.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/providers/stamp_cards_init_loaded_provider.dart';
import 'package:carol/providers/stamp_cards_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/providers/stores_init_loaded_provider.dart';
import 'package:carol/providers/stores_provider.dart';

/// Handles both fetching and registering providers.
Future<void> reloadCustomerEntities({
  required User currentUser,
  required StampCardsInitLoadedNotifier stampCardsInitLoadedNotifier,
  required StampCardsNotifier stampCardsNotifier,
  required StoresInitLoadedNotifier customerStoresInitLoadedNotifier,
  required StoresNotifier customerStoresNotifier,
}) async {
  // Cards
  final stampCards = await listStampCards(
    customerId: currentUser.id,
  );

  // Blueprints
  final blueprints = await listBlueprints(
    blueprintIds: stampCards.map((e) => e.blueprintId).toSet(),
  );
  // Stores
  final stores = await listStores(
    storeIds: blueprints.map((e) => e.storeId).toSet(),
  );

  // Bind blueprints to stores
  final storeMap = stores.fold(<int, Store>{}, (previousValue, store) {
    store.blueprints = [];
    previousValue[store.id] = store;
    return previousValue;
  });
  for (final blueprint in blueprints) {
    storeMap[blueprint.storeId]!.blueprints!.add(blueprint);
  }

  // Register to providers
  customerStoreProviders.tryAddProviders(entities: stores);
  blueprintProviders.tryAddProviders(entities: blueprints);
  for (final blueprint in blueprints) {
    redeemRuleProviders.tryAddProviders(entities: blueprint.redeemRules ?? []);
  }
  stampCardProviders.tryAddProviders(entities: stampCards);

  stampCardsNotifier.set(stampCards.toList());
  stampCardsInitLoadedNotifier.set(true);
  customerStoresNotifier.set(stores.toList());
  customerStoresInitLoadedNotifier.set(true);
}

/// Assumes blueprint is not fetched (null).
///
/// In real practice, all Many-to-One associations are EAGERLY fetched from backend, so response includes every associated blueprint and store.
Future<Set<StampCard>> listStampCards({
  String? customerId,
  Set<int>? stampCardIds,
}) async {
  if (customerId == null && (stampCardIds == null || stampCardIds.isEmpty)) {
    return {};
  }

  final url = Uri.http(
    backend_params.apigateway,
    backend_params.customerStampCardListPath,
    {
      if (customerId != null) 'customerId': customerId,
      if (stampCardIds != null && stampCardIds.isNotEmpty)
        'ids': stampCardIds.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(url);

  List<dynamic> resBody = json.decode(res.body);
  Set<StampCard> stampCards = {};
  for (final map in resBody) {
    final stampCard = StampCard.fromJson(map);
    stampCards.add(stampCard);
  }
  return stampCards;
}

/// Unlike owner_apis, this doesn't fetch unpublished blueprints.
Future<Set<StampCardBlueprint>> listBlueprints({
  int? storeId,
  Set<int>? blueprintIds,
}) async {
  if (storeId == null && (blueprintIds == null || blueprintIds.isEmpty)) {
    return {};
  }

  final url = Uri.http(
    backend_params.apigateway,
    backend_params.customerBlueprintListPath,
    {
      if (storeId != null) 'storeId': storeId.toString(),
      if (blueprintIds != null && blueprintIds.isNotEmpty)
        'ids': blueprintIds.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(url);

  List<dynamic> resBody = json.decode(res.body);
  Set<StampCardBlueprint> blueprints = {};
  for (final map in resBody) {
    final blueprint = StampCardBlueprint.fromJson(map);
    blueprints.add(blueprint);
  }
  return blueprints;
}

Future<StampCardBlueprint> getBlueprint({
  required int id,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.customerBlueprintPath}/$id',
  );
  final res = await httpGet(url);
  Map<String, dynamic> resBody = json.decode(res.body);
  return StampCardBlueprint.fromJson(resBody);
}

Future<Set<Store>> listStores({
  // String? ownerId, // Owner service only
  Set<int>? storeIds,
}) async {
  if (storeIds == null || storeIds.isEmpty) {
    return {};
  }

  final url = Uri.http(
    backend_params.apigateway,
    backend_params.customerStoreListPath,
    {
      'ids': storeIds.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(url);

  List<dynamic> resBody = json.decode(res.body);
  Set<Store> stores = {};
  for (final json in resBody) {
    final store = Store.fromJson(json);
    stores.add(store);
  }
  return stores;
}

Future<List<RedeemRule>> listRedeemRules({
  required int blueprintId,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.customerRedeemRuleListPath,
    {
      'blueprintId': blueprintId.toString(),
    },
  );
  final res = await httpGet(url);
  List<dynamic> resBody = json.decode(res.body);
  Set<RedeemRule> redeemRules = {};
  for (final map in resBody) {
    final redeemRule = RedeemRule.fromJson(map);
    redeemRules.add(redeemRule);
  }
  return redeemRules.toList();
}

Future<int> getNumIssuedCards({
  required String customerId,
  required int blueprintId,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.customerNumIssuedCardsPath,
    {
      'customerId': customerId,
      'blueprintId': blueprintId.toString(),
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<int> postStampCard({
  required StampCard stampCard,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.customerStampCardPath,
  );
  final stampCardJson = stampCard.toJson();
  stampCardJson['id'] = null;
  final res = await httpPost(
    url,
    body: json.encode(stampCardJson, toEncodable: customToEncodable),
  );
  final location = res.headers['location']!; // e.g., '/api/v1/stampCard/{uuid}'
  final newStampCardId = backend_params.customerStampCardLocationPattern
      .firstMatch(location)!
      .group(0)!;
  return int.parse(newStampCardId);
}

Future<StampCard> getStampCard({
  required int id,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.customerStampCardPath}/$id',
  );
  final res = await httpGet(url);
  Map<String, dynamic> resBody = json.decode(res.body);
  return StampCard.fromJson(resBody);
}

Future<void> putStampCard({
  required int id,
  required StampCard stampCard,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.customerStampCardPath}/$id',
  );
  await httpPut(
    url,
    body: json.encode(stampCard.toJson(), toEncodable: customToEncodable),
  );
  return;
}

Future<void> softDeleteStampCard({
  required int id,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.customerStampCardPath}/$id',
  );
  await httpDelete(url);
  return;
}

Future<String> postRedeemRequest({
  required RedeemRequest redeemRequest,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.customerRedeemRequestPath,
  );
  final redeemRequestJson = redeemRequest.toJson();
  redeemRequestJson['id'] = null;
  final res = await httpPost(
    url,
    body: json.encode(redeemRequestJson, toEncodable: customToEncodable),
  );
  final location = res.headers['location']!;
  final newId = backend_params.customerRedeemRequestLocationPattern
      .firstMatch(location)!
      .group(0)!;
  return newId;
}

Future<void> deleteRedeemRequest({
  required String id,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.customerRedeemRequestPath}/$id',
  );
  await httpDelete(url);
  return;
}

Future<bool> redeemRequestExists({
  required String id,
}) async {
  final url = Uri.http(backend_params.apigateway,
      backend_params.customerRedeemRequestExistsPath, {
    'id': id,
  });
  final res = await httpGet(url);
  return bool.parse(res.body);
}

Future<bool> redeemExists({
  required String redeemRequestId,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.customerRedeemExistsPath,
    {
      'redeemRequestId': redeemRequestId,
    },
  );
  final res = await httpGet(url);
  return bool.parse(res.body);
}
