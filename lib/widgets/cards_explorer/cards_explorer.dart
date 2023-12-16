import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:flutter/material.dart';

class CardsExplorer extends StatefulWidget {
  const CardsExplorer({
    super.key,
  });

  @override
  State<CardsExplorer> createState() => _CardsExplorerState();
}

class _CardsExplorerState extends State<CardsExplorer> {
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
            children: [
              // CardsExplorerControlBar(),
              Expanded(
                child: CardsList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
