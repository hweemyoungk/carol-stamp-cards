import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/widgets/redeem_rules_explorer/redeem_rule_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RedeemRulesList extends ConsumerStatefulWidget {
  final List<RedeemRule> redeemRules;
  final StampCard? card;
  const RedeemRulesList({
    super.key,
    required this.redeemRules,
    required this.card,
  });

  @override
  ConsumerState<RedeemRulesList> createState() => _RedeemRulesListState();
}

class _RedeemRulesListState extends ConsumerState<RedeemRulesList> {
  late AppLocalizations _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    final redeemRules = widget.redeemRules;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _localizations.rewards,
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: redeemRules.length,
          itemBuilder: (ctx, index) {
            final redeemRule = redeemRules[index];
            return RedeemRuleListItem(
              key: ValueKey(
                  '${widget.card?.id.toString() ?? ''}:${redeemRule.id}'),
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
