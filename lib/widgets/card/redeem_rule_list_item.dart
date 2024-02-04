import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/screens/redeem_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedeemRuleListItem extends ConsumerStatefulWidget {
  final StampCard card;
  final RedeemRule redeemRule;
  final TextStyle style;
  final Color color;

  const RedeemRuleListItem({
    super.key,
    required this.card,
    required this.redeemRule,
    required this.style,
    required this.color,
  });

  @override
  ConsumerState<RedeemRuleListItem> createState() => _RedeemRuleListItemState();
}

class _RedeemRuleListItemState extends ConsumerState<RedeemRuleListItem> {
  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final redeemRule = widget.redeemRule;
    final redeemable = redeemRule.consumes <= card.numCollectedStamps;
    final appliedColor =
        redeemable ? widget.color : widget.color.withOpacity(.2);
    return ListTile(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (ctx) {
            return RedeemDialogScreen(
              card: card,
              redeemRule: redeemRule,
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
