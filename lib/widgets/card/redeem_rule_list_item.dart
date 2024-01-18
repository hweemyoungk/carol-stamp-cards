import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/screens/redeem_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedeemRuleListItem extends ConsumerStatefulWidget {
  const RedeemRuleListItem({
    super.key,
    required this.redeemRuleProvider,
    required this.stampCardProvider,
    required this.style,
    required this.color,
  });

  final StateNotifierProvider<EntityStateNotifier<RedeemRule>, RedeemRule>
      redeemRuleProvider;
  final StateNotifierProvider<EntityStateNotifier<StampCard>, StampCard>
      stampCardProvider;
  final TextStyle style;
  final Color color;

  @override
  ConsumerState<RedeemRuleListItem> createState() => _RedeemRuleListItemState();
}

class _RedeemRuleListItemState extends ConsumerState<RedeemRuleListItem> {
  @override
  Widget build(BuildContext context) {
    final stampCard = ref.watch(widget.stampCardProvider);
    final redeemRule = ref.watch(widget.redeemRuleProvider);
    final redeemable = redeemRule.consumes <= stampCard.numCollectedStamps;
    final appliedColor =
        redeemable ? widget.color : widget.color.withOpacity(.2);
    return ListTile(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (ctx) {
            return RedeemDialogScreen(
              stampCardProvider: stampCardProviders.providers[stampCard.id]!,
              redeemRuleProvider: widget.redeemRuleProvider,
            );
          },
        );
      },
      key: ValueKey(redeemRule.id),
      leading: redeemRule.consumesWidget(
        widget.style,
        appliedColor,
      ),
      title: Text(
        redeemRule.displayName,
        style: widget.style.copyWith(color: appliedColor),
      ),
    );
  }
}
