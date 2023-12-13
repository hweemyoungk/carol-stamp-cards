import 'package:carol/main.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/cards_explorer/cards_explorer_control_bar.dart';
import 'package:flutter/material.dart';

class CardsExplorer extends StatefulWidget {
  const CardsExplorer({
    super.key,
    required this.parentContext,
  });

  final BuildContext parentContext;

  @override
  State<CardsExplorer> createState() => _CardsExplorerState();
}

class _CardsExplorerState extends State<CardsExplorer> {
  @override
  void initState() {
    super.initState();
    MyApp.activeContext = context;
  }

  @override
  void dispose() {
    MyApp.activeContext = widget.parentContext;
    super.dispose();
  }

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
          child: Column(
            children: [
              // CardsExplorerControlBar(),
              Expanded(
                child: CardsList(
                  parentContext: context,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
