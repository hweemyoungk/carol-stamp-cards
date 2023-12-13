import 'package:carol/data/dummy_data.dart';
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/redeem_rule_list_item.dart';
import 'package:flutter/material.dart';

class RedeemRulesList extends StatefulWidget {
  final StampCard stampCard;
  final BuildContext parentContext;

  const RedeemRulesList({
    super.key,
    required this.stampCard,
    required this.parentContext,
  });

  @override
  State<RedeemRulesList> createState() => _RedeemRulesListState();
}

class _RedeemRulesListState extends State<RedeemRulesList> {
  List<RedeemRule>? _redeemRules;

  @override
  void initState() {
    super.initState();
    MyApp.activeContext = context;
    loadRedeemRules().then((value) {
      setState(() {
        _redeemRules = value;
      });
    });
  }

  @override
  void dispose() {
    MyApp.activeContext = widget.parentContext;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Rewards',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        _redeemRules == null
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
                itemCount: _redeemRules!.length,
                itemBuilder: (ctx, index) {
                  final redeemRule = _redeemRules![index];
                  return RedeemRuleListItem(
                    redeemRule: redeemRule,
                    stampCard: widget.stampCard,
                    style: Theme.of(context).textTheme.titleLarge!,
                    color: Theme.of(context).colorScheme.onSecondary,
                    parentContext: widget.parentContext,
                  );
                },
              )
      ],
    );
  }

  Future<List<RedeemRule>> loadRedeemRules() async {
    await Future.delayed(const Duration(seconds: 1));
    return genDummySortedRedeemRules(widget.stampCard);
  }
}
