import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/utils.dart';

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
