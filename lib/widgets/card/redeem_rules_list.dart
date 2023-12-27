import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/redeem_rule_provider.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/redeem_rule_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RedeemRulesList extends ConsumerStatefulWidget {
  final StateNotifierProvider<EntityStateNotifier<StampCard>, StampCard>
      stampCardProvider;

  const RedeemRulesList({
    super.key,
    required this.stampCardProvider,
  });

  @override
  ConsumerState<RedeemRulesList> createState() => _RedeemRulesListState();
}

class _RedeemRulesListState extends ConsumerState<RedeemRulesList> {
  final List<RedeemRule> _redeemRules = [];
  bool _redeemRulesInitLoaded = false;

  @override
  void initState() {
    super.initState();
    loadRedeemRules().then((value) {
      setState(() {
        _redeemRules.addAll(value);
        _redeemRulesInitLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchedRedeemRules = _redeemRules.map(
      (redeemRule) {
        return ref.watch(redeemRuleProviders.providers[redeemRule.id]!);
      },
    ).toList();
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
        !_redeemRulesInitLoaded
            ? Padding(
                padding: Utils.basicWidgetEdgeInsets(5.0),
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading rewards...',
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: watchedRedeemRules.length,
                itemBuilder: (ctx, index) {
                  final redeemRule = watchedRedeemRules[index];
                  return RedeemRuleListItem(
                    redeemRuleProvider:
                        redeemRuleProviders.providers[redeemRule.id]!,
                    stampCardProvider: widget.stampCardProvider,
                    style: Theme.of(context).textTheme.titleLarge!,
                    color: Theme.of(context).colorScheme.onSecondary,
                  );
                },
              )
      ],
    );
  }

  Future<List<RedeemRule>> loadRedeemRules() async {
    await Future.delayed(const Duration(seconds: 1));
    return genDummySortedRedeemRules(ref.read(widget.stampCardProvider));
  }
}
