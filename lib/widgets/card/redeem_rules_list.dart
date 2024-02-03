import 'package:carol/models/stamp_card.dart';
import 'package:carol/widgets/card/redeem_rule_list_item.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedeemRulesList extends ConsumerStatefulWidget {
  final StampCard card;
  const RedeemRulesList({
    super.key,
    required this.card,
  });

  @override
  ConsumerState<RedeemRulesList> createState() => _RedeemRulesListState();
}

class _RedeemRulesListState extends ConsumerState<RedeemRulesList> {
  @override
  Widget build(BuildContext context) {
    final redeemRules = widget.card.blueprint?.redeemRules?.toList();
    if (redeemRules == null) {
      return const Loading(message: 'Loading redeem rules...');
    }

    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Rewards',
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        // redeemRules == null
        //     ? Padding(
        //         padding: DesignUtils.basicWidgetEdgeInsets(5.0),
        //         child: CircularProgressIndicator(
        //           semanticsLabel: 'Loading rewards...',
        //           color: Theme.of(context).colorScheme.onSecondary,
        //         ),
        //       )
        //     :
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: redeemRules.length,
          itemBuilder: (ctx, index) {
            final redeemRule = redeemRules[index];
            return RedeemRuleListItem(
              key: ValueKey('${widget.card.id}:${redeemRule.id}'),
              card: widget.card,
              redeemRule: redeemRule,
              style: Theme.of(context).textTheme.titleLarge!,
              color: Theme.of(context).colorScheme.onSecondary,
            );
          },
        )
      ],
    );
  }
}
