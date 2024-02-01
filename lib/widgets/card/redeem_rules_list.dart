import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/redeem_rule_provider.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/redeem_rule_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedeemRulesList extends ConsumerStatefulWidget {
  final StateNotifierProvider<EntityStateNotifier<StampCard>, StampCard>
      stampCardProvider;
  final StateNotifierProvider<EntityStateNotifier<StampCardBlueprint>,
      StampCardBlueprint> blueprintProvider;

  const RedeemRulesList({
    super.key,
    required this.stampCardProvider,
    required this.blueprintProvider,
  });

  @override
  ConsumerState<RedeemRulesList> createState() => _RedeemRulesListState();
}

class _RedeemRulesListState extends ConsumerState<RedeemRulesList> {
  @override
  Widget build(BuildContext context) {
    final blueprint = ref.watch(widget.blueprintProvider);
    final redeemRules = blueprint._redeemRules;
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
        redeemRules == null
            ? Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(5.0),
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading rewards...',
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: redeemRules.length,
                itemBuilder: (ctx, index) {
                  final redeemRule = redeemRules[index];
                  final provider = redeemRuleProviders.tryGetProviderById(
                      id: redeemRule.id)!;
                  // if (provider == null) {
                  //   redeemRuleProviders.tryAddProvider(entity: redeemRule);
                  //   provider = redeemRuleProviders.tryGetProviderById(
                  //     id: redeemRule.id,
                  //   )!;
                  // }
                  return RedeemRuleListItem(
                    redeemRuleProvider: provider,
                    stampCardProvider: widget.stampCardProvider,
                    style: Theme.of(context).textTheme.titleLarge!,
                    color: Theme.of(context).colorScheme.onSecondary,
                  );
                },
              )
      ],
    );
  }
}
