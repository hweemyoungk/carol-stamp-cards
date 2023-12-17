import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/screens/redeem_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedeemRuleListItem extends ConsumerStatefulWidget {
  const RedeemRuleListItem({
    super.key,
    required this.redeemRule,
    required this.stampCardProvider,
    required this.style,
    required this.color,
  });

  final RedeemRule redeemRule;
  final StateNotifierProvider<StampCardNotifier, StampCard> stampCardProvider;
  final TextStyle style;
  final Color color;

  @override
  ConsumerState<RedeemRuleListItem> createState() => _RedeemRuleListItemState();
}

class _RedeemRuleListItemState extends ConsumerState<RedeemRuleListItem> {
  @override
  Widget build(BuildContext context) {
    final stampCard = ref.watch(widget.stampCardProvider);
    final redeemable =
        widget.redeemRule.consumes <= stampCard.numCollectedStamps;
    final appliedColor =
        redeemable ? widget.color : widget.color.withOpacity(.2);
    return ListTile(
      onTap: !redeemable
          ? null
          : () async {
              await showDialog(
                context: context,
                builder: (ctx) {
                  return RedeemDialogScreen(
                    stampCardProvider:
                        StampCardProviders.providers[stampCard.id]!,
                    redeemRule: widget.redeemRule,
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
