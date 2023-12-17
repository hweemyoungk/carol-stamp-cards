import 'package:carol/utils.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';

class StoresExplorer extends StatefulWidget {
  const StoresExplorer({super.key});

  @override
  State<StoresExplorer> createState() => _StoresExplorerState();
}

class _StoresExplorerState extends State<StoresExplorer> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          alignment: Alignment.center,
          margin: Utils.basicScreenEdgeInsets(ctx, constraints),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // color: Theme.of(context).colorScheme.primary,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // StoresListControlBar(),
              StoresList(),
            ],
          ),
        );
      },
    );
  }
}
