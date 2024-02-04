import 'package:carol/models/redeem_request.dart';
import 'package:carol/providers/redeem_requests_notifier.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ownerRedeemRequestsListRedeemRequestsProvider =
    StateNotifierProvider<RedeemRequestsNotifier, List<RedeemRequest>?>(
        (ref) => RedeemRequestsNotifier(null));

class RedeemRequestsList extends ConsumerStatefulWidget {
  const RedeemRequestsList({super.key});

  @override
  ConsumerState<RedeemRequestsList> createState() => _RedeemRequestsListState();
}

class _RedeemRequestsListState extends ConsumerState<RedeemRequestsList> {
  @override
  Widget build(BuildContext context) {
    final redeemRequests =
        ref.watch(ownerRedeemRequestsListRedeemRequestsProvider);

    return redeemRequests == null
        ? const CircularProgressIndicator()
        : redeemRequests.isEmpty
            ? Center(
                child: Text(
                  'No data found!',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: redeemRequests.length,
                  itemBuilder: (ctx, index) {
                    final redeemRequest = redeemRequests[index];
                    if (redeemRequest.ttlMilliseconds < 0) {
                      return null;
                    }
                    return RedeemRequestsListItem(
                      key: ValueKey(redeemRequest.id),
                      redeemRequest: redeemRequest,
                    );
                  },
                ),
              );
  }
}
