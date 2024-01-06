import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/utils.dart';

Future<List<Store>> loadStores(
    {required String userId, required int numStores}) async {
  await Future.delayed(const Duration(seconds: 1));
  return genDummyStores(numStores: numStores, ownerId: currentUser.id);
}

Future<List<RedeemRule>> listDummyRedeemRules({
  required StampCardBlueprint blueprint,
}) async {
  await Utils.delaySeconds(2);
  return Future.sync(() => genDummySortedRedeemRules(
        blueprint: blueprint,
        numRules: 3,
      ));
}
