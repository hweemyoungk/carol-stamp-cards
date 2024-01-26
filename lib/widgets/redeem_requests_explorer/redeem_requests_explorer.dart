import 'package:carol/utils.dart';
import 'package:carol/widgets/redeem_requests_explorer/redeem_requests_list.dart';
import 'package:flutter/material.dart';

class RedeemRequestsExplorer extends StatefulWidget {
  const RedeemRequestsExplorer({super.key});

  @override
  State<RedeemRequestsExplorer> createState() => _RedeemRequestsExplorerState();
}

class _RedeemRequestsExplorerState extends State<RedeemRequestsExplorer> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          alignment: Alignment.center,
          margin: DesignUtils.basicScreenEdgeInsets(ctx, constraints),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // color: Theme.of(context).colorScheme.primary,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RedeemRequestsList(),
            ],
          ),
        );
      },
    );
  }
}
