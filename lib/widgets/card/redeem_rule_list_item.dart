import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/widgets/card/redeem_dialog.dart';
import 'package:flutter/material.dart';

class RedeemRuleListItem extends StatefulWidget {
  const RedeemRuleListItem({
    super.key,
    required this.redeemRule,
    required this.stampCard,
    required this.style,
    required this.color,
    required this.parentContext,
  });

  final RedeemRule redeemRule;
  final StampCard stampCard;
  final TextStyle style;
  final Color color;
  final BuildContext parentContext;

  @override
  State<RedeemRuleListItem> createState() => _RedeemRuleListItemState();
}

class _RedeemRuleListItemState extends State<RedeemRuleListItem> {
  late Widget redeemButton;

  @override
  void initState() {
    super.initState();
    MyApp.activeContext = context;
  }

  @override
  void dispose() {
    MyApp.activeContext = widget.parentContext;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final redeemable =
        widget.redeemRule.consumes <= widget.stampCard.numCollectedStamps;
    final appliedColor =
        redeemable ? widget.color : widget.color.withOpacity(.2);
    return ListTile(
      onTap: !redeemable
          ? null
          : () async {
              await showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: Text(widget.redeemRule.displayName),
                    content: RedeemDialog(
                      redeemRule: widget.redeemRule,
                      stampCard: widget.stampCard,
                      parentContext: widget.parentContext,
                    ),
                  );
                },
              );
            },
      key: ValueKey(widget.redeemRule.id),
      leading: widget.redeemRule.consumesWidget(
        widget.style,
        appliedColor,
      ),
      title: Text(
        widget.redeemRule.displayName,
        style: widget.style.copyWith(color: appliedColor),
      ),
      trailing: Icon(
        widget.redeemRule.icon,
        color: appliedColor,
      ),
    );
  }
}
