import 'package:carol/models/redeem_rule.dart';
import 'package:carol/providers/list_notifier.dart';

class RedeemRulesNotifier extends ListNotifier<RedeemRule> {
  RedeemRulesNotifier(List<RedeemRule>? state) : super(state);

  @override
  void sort() {
    if (state == null) {
      return;
    }
    state!.sort(
      (redeemRule1, redeemRule2) =>
          redeemRule1.consumes.compareTo(redeemRule2.consumes),
    );
    state = [...state!];
  }
}
