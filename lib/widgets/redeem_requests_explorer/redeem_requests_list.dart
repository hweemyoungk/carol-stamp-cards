import 'package:carol/providers/boolean_notifier.dart';
import 'package:carol/providers/redeem_requests_provider.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ownerRedeemRequestsInitLoadedProvider =
    StateNotifierProvider<BooleanNotifier, bool>(
        (ref) => BooleanNotifier(false));

class RedeemRequestsList extends ConsumerStatefulWidget {
  const RedeemRequestsList({super.key});

  @override
  ConsumerState<RedeemRequestsList> createState() => _RedeemRequestsListState();
}

class _RedeemRequestsListState extends ConsumerState<RedeemRequestsList> {
  @override
  Widget build(BuildContext context) {
    final redeemRequests = ref.watch(ownerRedeemRequestsProvider);
    final redeemRequestsInitLoaded =
        ref.watch(ownerRedeemRequestsInitLoadedProvider);

    return !redeemRequestsInitLoaded
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
                    final redeemRuleProvider =
                        redeemRuleProviders.tryGetProviderById(
                      id: redeemRequest.redeemRuleId,
                    )!;
                    final blueprintProvider =
                        blueprintProviders.tryGetProviderById(
                            id: ref.read(redeemRuleProvider).blueprintId)!;
                    final storeProvider =
                        ownerStoreProviders.tryGetProviderById(
                      id: ref.read(blueprintProvider).storeId,
                    )!;
                    return RedeemRequestsListItem(
                      key: ValueKey(redeemRequest.id),
                      redeemRequest: redeemRequest,
                      storeProvider: storeProvider,
                      blueprintProvider: blueprintProvider,
                      redeemRuleProvider: redeemRuleProvider,
                    );
                  },
                ),
              );
  }
}
