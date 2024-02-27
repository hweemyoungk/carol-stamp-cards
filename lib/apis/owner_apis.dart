import 'dart:convert';

import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/params/backend.dart' as backend_params;
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> reloadOwnerModels(WidgetRef ref) async {
  final currentUser = ref.read(currentUserProvider)!;
  final storesNotifier = ref.read(ownerStoresListStoresProvider.notifier);

  // Set loading
  storesNotifier.set(null);

  final Set<Store> stores;
  try {
    stores = await listStores(ownerId: currentUser.id);
  } on Exception catch (e) {
    Carol.showExceptionSnackBar(
      e,
      contextMessage: 'Failed to load owner models.',
    );
    storesNotifier.set([]);
    return;
  }

  // Propagate: ownerStoresListStoresProvider
  storesNotifier.set(stores.toList());
}

// Future<void> reloadOwnerRedeemRequests({
//   required RedeemRequestsInitLoadedNotifier
//       ownerRedeemRequestsInitLoadedNotifier,
//   required RedeemRequestsNotifier ownerRedeemRequestsNotifier,
//   required String ownerId,
// }) async {
//   ownerRedeemRequestsInitLoadedNotifier.set(false);

//   // Load redeem requests
//   final redeemRequests = await listRedeemRequests(ownerId: ownerId);
//   ownerRedeemRequestsNotifier.set(redeemRequests);

//   // Load associated redeem rules
//   final redeemRules = await listRedeemRules(
//     ids: redeemRequests.map((e) => e.redeemRuleId).toSet(),
//   );
//   redeemRuleProviders.tryAddProviders(entities: redeemRules);

//   // Load associated blueprints
//   final blueprints = await listBlueprints(
//     blueprintIds: redeemRules.map((e) => e.blueprintId).toSet(),
//   );
//   blueprintProviders.tryAddProviders(entities: blueprints);

//   // Load associated stores
//   final stores = await listStores(
//     storeIds: blueprints.map((e) => e.storeId).toSet(),
//   );
//   ownerStoreProviders.tryAddProviders(entities: stores);

//   ownerRedeemRequestsInitLoadedNotifier.set(true);
// }

// Future<List<RedeemRule>> listDummyRedeemRules({
//   required Blueprint blueprint,
// }) async {
//   await DesignUtils.delaySeconds(2);
//   return Future.sync(
//     () => genDummySortedRedeemRules(
//       blueprint: blueprint,
//       numRules: 3,
//     ),
//   );
// }

Future<Set<RedeemRule>> listRedeemRules({
  int? blueprintId,
  Set<int>? ids,
}) async {
  if (blueprintId == null && (ids == null || ids.isEmpty)) {
    return {};
  }
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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

Future<Set<RedeemRequest>> listRedeemRequests({
  required String ownerId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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
  return redeemRequests;
}

Future<void> approveRedeemRequest({
  required String redeemRequestId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.ownerRedeemRequestApprovePath(redeemRequestId),
  );
  await httpPost(url);
}

/// Unlike customer_apis, this fetches unpublished blueprints as well.
Future<Set<Blueprint>> listBlueprints({
  int? storeId,
  Set<int>? blueprintIds,
}) async {
  if (storeId == null && (blueprintIds == null || blueprintIds.isEmpty)) {
    return {};
  }

  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.ownerBlueprintListPath,
    {
      if (storeId != null) 'storeId': storeId.toString(),
      if (blueprintIds != null && blueprintIds.isNotEmpty)
        'ids': blueprintIds.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(url); // Can throw e

  List<dynamic> resBody = json.decode(res.body);
  Set<Blueprint> blueprints = {};
  for (final map in resBody) {
    final blueprint = Blueprint.fromJson(map);
    blueprints.add(blueprint);
  }
  return blueprints;
}

Future<int> postBlueprint({
  required Blueprint blueprint,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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

/// Blueprint has non-null redeemRules.</ol>
Future<Blueprint> getBlueprint({
  required int id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    '${backend_params.ownerBlueprintPath}/$id',
  );
  final res = await httpGet(url);
  Map<String, dynamic> resBody = json.decode(res.body);
  return Blueprint.fromJson(resBody);
}

Future<void> putBlueprint({
  required int id,
  required Blueprint blueprint,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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

/// Fetches stores for owner.<br>
/// <ol>Every store has non-null blueprints<b>(A)</b>.</ol>
/// <ol>Every blueprint<b>(A)</b> has non-null redeemRules.</ol>
Future<Set<Store>> listStores({
  String? ownerId,
  Set<int>? storeIds,
}) async {
  if (ownerId == null && (storeIds == null || storeIds.isEmpty)) {
    return {};
  }

  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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

Future<void> closeStore({
  required int id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    '${backend_params.ownerStorePath}/$id',
  );
  await httpDelete(url);
  return;
}

Future<int> getNumAccumulatedTotalStores({
  required String ownerId,
}) async {
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.ownerNumAccumulatedTotalStoresPath,
    {
      'ownerId': ownerId,
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<int> getNumCurrentTotalStores({
  required String ownerId,
}) async {
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.ownerNumCurrentTotalStoresPath,
    {
      'ownerId': ownerId,
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<int> getNumCurrentActiveStores({
  required String ownerId,
}) async {
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.ownerNumCurrentActiveStoresPath,
    {
      'ownerId': ownerId,
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<StampCard> getStampCard({
  required int id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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

/* 
// Owner doesn't post Redeem directly.

Future<String> postRedeem({
  required Redeem redeem,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
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
 */
