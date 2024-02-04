import 'package:carol/models/redeem_request.dart';
import 'package:carol/providers/list_notifier.dart';

class RedeemRequestsNotifier extends ListNotifier<RedeemRequest> {
  RedeemRequestsNotifier(super.state);

  @override
  void sort() {}
}
