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
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> reloadCustomerModels(WidgetRef ref) async {
  final currentUser = ref.read(currentUserProvider)!;
  final cardsNotifier = ref.read(customerCardsListCardsProvider.notifier);
  final storesNotifier = ref.read(customerStoresListStoresProvider.notifier);

  final Set<StampCard> cards;
  try {
    cards = await listStampCards(customerId: currentUser.id);
  } on Exception catch (e) {
    cardsNotifier.set([]);
    storesNotifier.set([]);
    Carol.showExceptionSnackBar(
      e,
      contextMessage: 'Failed to load customer models.',
    );
    return;
  }

  // Propagate: customerCardsListCardsProvider,customerStoresListStoresProvider
  cardsNotifier.set(cards.toList());
  final blueprints = cards
      .map((stampCard) => stampCard.blueprint)
      .where((element) => element != null)
      .cast<Blueprint>()
      .toSet();
  final stores = blueprints
      .map((blueprint) => blueprint.store)
      .where((element) => element != null)
      .cast<Store>()
      .toSet();
  storesNotifier.set(stores.toList());
}

/// Fetches cards for customer.<br>
/// <ol>Every card has a non-null blueprint<b>(A)</b>.</ol>
/// <ol>Every blueprint<b>(A)</b> has a non-null store<b>(B)</b> and <i>null</i> redeemRules.</ol>
/// <ol>Every store<b>(B)</b> has a non-null set of blueprint<b>(C)</b>s.</ol>
/// <ol>Every blueprint<b>(C)</b> has <i>null</i> redeemRules.</ol>
Future<Set<StampCard>> listStampCards({
  String? customerId,
  Set<int>? stampCardIds,
}) async {
  if (customerId == null && (stampCardIds == null || stampCardIds.isEmpty)) {
    return {};
  }

  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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
    backend_params.customerBlueprintListPath,
    {
      if (storeId != null) 'storeId': storeId.toString(),
      if (blueprintIds != null && blueprintIds.isNotEmpty)
        'ids': blueprintIds.map((e) => e.toString()).toList(),
    },
  );
  final res = await httpGet(url);

  List<dynamic> resBody = json.decode(res.body);
  Set<Blueprint> blueprints = {};
  for (final map in resBody) {
    final blueprint = Blueprint.fromJson(map);
    blueprints.add(blueprint);
  }
  return blueprints;
}

/// Fetches a blueprint for customer.<br>
/// Blueprint has non-null redeemRules.
Future<Blueprint> getBlueprint({
  required int id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    '${backend_params.customerBlueprintPath}/$id',
  );
  final res = await httpGet(url);
  Map<String, dynamic> resBody = json.decode(res.body);
  return Blueprint.fromJson(resBody);
}

Future<Set<Store>> listStores({
  // String? ownerId, // Owner service only
  Set<int>? storeIds,
}) async {
  if (storeIds == null || storeIds.isEmpty) {
    return {};
  }

  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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

Future<Store> getStore({
  required int id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    '${backend_params.customerStorePath}/$id',
  );
  final res = await httpGet(url);
  Map<String, dynamic> resBody = json.decode(res.body);
  return Store.fromJson(resBody);
}

Future<Set<RedeemRule>> listRedeemRules({
  required int blueprintId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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
  return redeemRules;
}

Future<int> getNumCustomerIssuedCards({
  required String customerId,
  required int blueprintId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerNumCustomerIssuedCardsPath,
    {
      'customerId': customerId,
      'blueprintId': blueprintId.toString(),
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<int> getNumTotalIssuedCards({
  required int blueprintId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerNumTotalIssuedCardsPath,
    {
      'blueprintId': blueprintId.toString(),
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<int> getNumAccumulatedTotalCards({
  required String customerId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerNumAccumulatedTotalCardsPath,
    {
      'customerId': customerId,
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<int> getNumCurrentTotalCards({
  required String customerId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerNumCurrentTotalCards,
    {
      'customerId': customerId,
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<int> getNumCurrentActiveCards({
  required String customerId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerNumCurrentActiveCards,
    {
      'customerId': customerId,
    },
  );
  final res = await httpGet(url);
  return int.parse(res.body);
}

Future<int> postStampCard({
  required StampCard stampCard,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerStampCardPath,
  );
  final stampCardJson = stampCard.toJson();
  stampCardJson['id'] = null;
  final res = await httpPost(
    url,
    body: json.encode(stampCardJson, toEncodable: customToEncodable),
  );
  final location = res.headers['location']!; // e.g., '/api/v1/stampCard/{uuid}'
  // final newStampCardId = backend_params.customerStampCardLocationPattern
  //     .firstMatch(location)!
  //     .group(0)!;
  final newStampCardId = getIdFromLocation(location);
  return int.parse(newStampCardId);
}

Future<StampCard> getStampCard({
  required int id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
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
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    '${backend_params.customerStampCardPath}/$id',
  );
  await httpPut(
    url,
    body: json.encode(stampCard.toJson(), toEncodable: customToEncodable),
  );
  return;
}

Future<void> discardStampCard({
  required int id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    '${backend_params.customerStampCardPath}/$id',
  );
  await httpDelete(url);
  return;
}

Future<String> postRedeemRequest({
  required RedeemRequest redeemRequest,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerRedeemRequestPath,
  );
  final redeemRequestJson = redeemRequest.toJson();
  redeemRequestJson['id'] = null;
  redeemRequestJson['expMilliseconds'] = null;
  final res = await httpPost(
    url,
    body: json.encode(redeemRequestJson, toEncodable: customToEncodable),
  );
  final location = res.headers['location']!;
  // final newId = backend_params.customerRedeemRequestLocationPattern
  //     .firstMatch(location)!
  //     .group(0)!;
  final newId = getIdFromLocation(location);
  return newId;
}

Future<void> deleteRedeemRequest({
  required String id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    '${backend_params.customerRedeemRequestPath}/$id',
  );
  await httpDelete(url);
  return;
}

Future<bool> redeemRequestExists({
  required String id,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerRedeemRequestExistsPath(id),
  );
  final res = await httpGet(url);
  return bool.parse(res.body);
}

Future<bool> redeemExists({
  required String redeemRequestId,
}) async {
  // final url = Uri.http(
  final url = Uri.https(
    backend_params.appGateway,
    backend_params.customerRedeemListExistsPath,
    {
      'redeemRequestId': redeemRequestId,
    },
  );
  final res = await httpGet(url);
  return bool.parse(res.body);
}
