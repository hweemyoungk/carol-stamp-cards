import 'dart:convert';

import 'package:carol/apis/utils.dart';
import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/redeem.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/params/backend.dart' as backend_params;
import 'package:carol/providers/redeem_requests_init_loaded_provider.dart';
import 'package:carol/providers/redeem_requests_provider.dart';
import 'package:carol/providers/redeem_rule_provider.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/utils.dart';

Future<void> reloadOwnerRedeemRequests({
  required RedeemRequestsInitLoadedNotifier
      ownerRedeemRequestsInitLoadedNotifier,
  required RedeemRequestsNotifier ownerRedeemRequestsNotifier,
  required String ownerId,
}) async {
  ownerRedeemRequestsInitLoadedNotifier.set(false);

  // Load redeem requests
  final redeemRequests = await listRedeemRequests(ownerId: ownerId);
  ownerRedeemRequestsNotifier.set(redeemRequests);

  // Load associated redeem rules
  final redeemRules = await listRedeemRules(
    ids: redeemRequests.map((e) => e.redeemRuleId).toSet(),
  );
  redeemRuleProviders.tryAddProviders(entities: redeemRules);

  // Load associated blueprints
  final blueprints = await listBlueprints(
    blueprintIds: redeemRules.map((e) => e.blueprintId).toSet(),
  );
  blueprintProviders.tryAddProviders(entities: blueprints);

  // Load associated stores
  final stores = await listStores(
    storeIds: blueprints.map((e) => e.storeId).toSet(),
  );
  ownerStoreProviders.tryAddProviders(entities: stores);

  ownerRedeemRequestsInitLoadedNotifier.set(true);
}

Future<List<RedeemRule>> listDummyRedeemRules({
  required StampCardBlueprint blueprint,
}) async {
  await DesignUtils.delaySeconds(2);
  return Future.sync(
    () => genDummySortedRedeemRules(
      blueprint: blueprint,
      numRules: 3,
    ),
  );
}

Future<Set<RedeemRule>> listRedeemRules({
  int? blueprintId,
  Set<int>? ids,
}) async {
  if (blueprintId == null && (ids == null || ids.isEmpty)) {
    return {};
  }
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerRedeemRuleListPath,
    {
      if (blueprintId != null) 'blueprintId': blueprintId.toString(),
      if (ids != null && ids.isNotEmpty)
        'ids': ids.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(url);
  List<dynamic> resBody = json.decode(res.body);
  Set<RedeemRule> redeemRules = {};
  for (final map in resBody) {
    final redeemRule = RedeemRule.fromJson(map);
    redeemRules.add(redeemRule);
  }
  return redeemRules;
}

Future<List<RedeemRequest>> listRedeemRequests({
  required String ownerId,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerRedeemRequestListPath,
    {
      'ownerId': ownerId,
    },
  );
  final res = await httpGet(url);
  List<dynamic> resBody = json.decode(res.body);
  Set<RedeemRequest> redeemRequests = {};
  for (final map in resBody) {
    final redeemRule = RedeemRequest.fromJson(map);
    redeemRequests.add(redeemRule);
  }
  return redeemRequests.toList();
}

Future<void> approveRedeemRequest({
  required String redeemRequestId,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerRedeemRequestApprovePath(redeemRequestId),
  );
  await httpPost(url);
}

/// Unlike customer_apis, this fetches unpublished blueprints as well.
Future<Set<StampCardBlueprint>> listBlueprints({
  int? storeId,
  Set<int>? blueprintIds,
}) async {
  if (storeId == null && (blueprintIds == null || blueprintIds.isEmpty)) {
    return {};
  }

  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerBlueprintListPath,
    {
      if (storeId != null) 'storeId': storeId.toString(),
      if (blueprintIds != null && blueprintIds.isNotEmpty)
        'ids': blueprintIds.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(url); // Can throw e

  List<dynamic> resBody = json.decode(res.body);
  Set<StampCardBlueprint> blueprints = {};
  for (final map in resBody) {
    final blueprint = StampCardBlueprint.fromJson(map);
    blueprints.add(blueprint);
  }
  return blueprints;
}

Future<int> postBlueprint({
  required StampCardBlueprint blueprint,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerBlueprintPath,
  );

  final blueprintJson = blueprint.toJson();
  blueprintJson['id'] = null;
  if (blueprintJson['redeemRules'] != null) {
    for (final redeemRule in blueprintJson['redeemRules']) {
      redeemRule['id'] = null;
      redeemRule['blueprintId'] = null;
    }
  }
  final res = await httpPost(
    url,
    body: json.encode(blueprintJson, toEncodable: customToEncodable),
  );
  final location = res.headers['location']!; // e.g., '/api/v1/stampCard/{uuid}'
  final newId = backend_params.ownerBlueprintLocationPattern
      .firstMatch(location)!
      .group(0)!;
  return int.parse(newId);
}

Future<StampCardBlueprint> getBlueprint({
  required int id,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.ownerBlueprintPath}/$id',
  );
  final res = await httpGet(url);
  Map<String, dynamic> resBody = json.decode(res.body);
  return StampCardBlueprint.fromJson(resBody);
}

Future<void> putBlueprint({
  required int id,
  required StampCardBlueprint blueprint,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.ownerBlueprintPath}/$id',
  );

  final blueprintJson = blueprint.toJson();
  if (blueprintJson['redeemRules'] != null) {
    for (final redeemRule in blueprintJson['redeemRules']) {
      if (redeemRule['id'] == -1) {
        redeemRule['id'] = null;
      }
    }
  }

  await httpPut(
    url,
    body: json.encode(blueprintJson, toEncodable: customToEncodable),
  );
  return;
}

Future<Set<Store>> listStores({
  String? ownerId,
  Set<int>? storeIds,
}) async {
  if (ownerId == null && (storeIds == null || storeIds.isEmpty)) {
    return {};
  }

  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerStoreListPath,
    {
      if (ownerId != null) 'ownerId': ownerId,
      if (storeIds != null && storeIds.isNotEmpty)
        'ids': storeIds.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(url); // Can throw e

  List<dynamic> resBody = json.decode(res.body);
  Set<Store> stores = {};
  for (final map in resBody) {
    final store = Store.fromJson(map);
    stores.add(store);
  }
  return stores;
}

Future<int> postStore({
  required Store store,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerStorePath,
  );

  final storeJson = store.toJson();
  storeJson['id'] = null;
  if (storeJson['blueprints'] != null) {
    for (final blueprint in storeJson['blueprints']) {
      blueprint['id'] = null;
    }
  }
  final res = await httpPost(
    url,
    body: json.encode(storeJson, toEncodable: customToEncodable),
  );
  final location = res.headers['location']!; // e.g., '/api/v1/stampCard/{uuid}'
  final newId =
      backend_params.ownerStoreLocationPattern.firstMatch(location)!.group(0)!;
  return int.parse(newId);
}

Future<Store> getStore({
  required int id,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.ownerStorePath}/$id',
  );
  final res = await httpGet(url);
  Map<String, dynamic> resBody = json.decode(res.body);
  return Store.fromJson(resBody);
}

Future<void> putStore({
  required int id,
  required Store store,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.ownerStorePath}/$id',
  );

  final storeJson = store.toJson();
  if (storeJson['blueprints'] != null) {
    for (final blueprint in storeJson['blueprints']) {
      if (blueprint['id'] == -1) {
        blueprint['id'] = null;
      }
    }
  }

  await httpPut(
    url,
    body: json.encode(storeJson, toEncodable: customToEncodable),
  );
  return;
}

Future<StampCard> getStampCard({
  required int id,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    '${backend_params.ownerStampCardPath}/$id',
  );
  final res = await httpGet(url);
  Map<String, dynamic> resBody = json.decode(res.body);
  return StampCard.fromJson(resBody);
}

Future<String> grantStamp({
  required int stampCardId,
  required int numStamps,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerStampGrantPath,
  );

  final bodyJson = {
    'cardId': stampCardId,
    'numStamps': numStamps,
  };

  final res = await httpPost(
    url,
    body: json.encode(bodyJson, toEncodable: customToEncodable),
  );
  final location = res.headers['location']!;
  final newId = backend_params.ownerStampGrantLocationPattern
      .firstMatch(location)!
      .group(0)!;
  return newId;
}

Future<String> postRedeem({
  required Redeem redeem,
}) async {
  final url = Uri.http(
    backend_params.apigateway,
    backend_params.ownerRedeemPath,
  );

  final redeemJson = redeem.toJson();
  redeemJson['id'] = null;
  if (redeemJson['blueprints'] != null) {
    for (final blueprint in redeemJson['blueprints']) {
      blueprint['id'] = null;
    }
  }
  final res = await httpPost(
    url,
    body: json.encode(redeemJson, toEncodable: customToEncodable),
  );
  final location = res.headers['location']!; // e.g., '/api/v1/stampCard/{uuid}'
  final newId = backend_params.customerStampCardLocationPattern
      .firstMatch(location)!
      .group(0)!;
  return newId;
}
