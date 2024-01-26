import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/screens/redeem_request_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedeemRequestsListItem extends ConsumerStatefulWidget {
  final RedeemRequest redeemRequest;
  final StateNotifierProvider<EntityStateNotifier<Store>, Store> storeProvider;
  final StateNotifierProvider<EntityStateNotifier<StampCardBlueprint>,
      StampCardBlueprint> blueprintProvider;
  final StateNotifierProvider<EntityStateNotifier<RedeemRule>, RedeemRule>
      redeemRuleProvider;
  const RedeemRequestsListItem({
    super.key,
    required this.redeemRequest,
    required this.storeProvider,
    required this.blueprintProvider,
    required this.redeemRuleProvider,
  });

  @override
  ConsumerState<RedeemRequestsListItem> createState() =>
      _RedeemRequestsListItemState();
}

class _RedeemRequestsListItemState
    extends ConsumerState<RedeemRequestsListItem> {
  @override
  Widget build(BuildContext context) {
    final redeemRule = ref.watch(widget.redeemRuleProvider);
    return ListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) {
            return RedeemRequestDialogScreen(
              redeemRequest: widget.redeemRequest,
              storeProvider: widget.storeProvider,
              blueprintProvider: widget.blueprintProvider,
              redeemRuleProvider: widget.redeemRuleProvider,
            );
          },
        );
      },
      leading: Text(widget.redeemRequest.customerDisplayName),
      title: Text(redeemRule.displayName),
      trailing: widget.redeemRequest.remainingSecondsWidget,
    );
  }
}
