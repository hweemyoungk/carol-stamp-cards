import 'package:carol/models/redeem_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Replace with ListNotifier
class RedeemRequestsNotifier extends StateNotifier<List<RedeemRequest>> {
  RedeemRequestsNotifier() : super([]);

  void set(List<RedeemRequest> redeemRequests) {
    state = redeemRequests;
  }

  void append(RedeemRequest redeemRequest) {
    state = [...state, redeemRequest];
  }

  void prepend(RedeemRequest redeemRequest) {
    state = [redeemRequest, ...state];
  }

  void appendAll(Iterable<RedeemRequest> redeemRequests) {
    state = [...state, ...redeemRequests];
  }

  void prependAll(Iterable<RedeemRequest> redeemRequests) {
    state = [...redeemRequests, ...state];
  }
}

final ownerRedeemRequestsProvider =
    StateNotifierProvider<RedeemRequestsNotifier, List<RedeemRequest>>(
        (ref) => RedeemRequestsNotifier());
