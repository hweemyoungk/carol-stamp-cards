import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardsExplorer extends ConsumerStatefulWidget {
  const CardsExplorer({
    super.key,
  });

  @override
  ConsumerState<CardsExplorer> createState() => _CardsExplorerState();
}

class _CardsExplorerState extends ConsumerState<CardsExplorer> {
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
              // CardsExplorerControlBar(),
              CardsList(),
            ],
          ),
        );
      },
    );
  }
}
