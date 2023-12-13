import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/card_info.dart';
import 'package:carol/widgets/card/redeem_rules_list.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CardScreen extends StatefulWidget {
  final StampCard stampCard;
  final BuildContext parentContext;
  const CardScreen({
    super.key,
    required this.stampCard,
    required this.parentContext,
  });

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  final loadableStoreInfo = ElevatedButton.icon(
    onPressed: _onPressLoadStoreInfo,
    icon: const Icon(Icons.store),
    label: const Text('Store Info'),
  );

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
    final cardInfo = CardInfo(stampCard: widget.stampCard);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final qrImageView = QrImageView(
            data: widget.stampCard.id,
            version: QrVersions.auto,
            size: constraints.maxWidth * 0.4,
          );
          final stampsRatioText = SizedBox(
            width: constraints.maxWidth * 0.4,
            child: Column(
              children: [
                Padding(
                  padding: Utils.basicWidgetEdgeInsets(.5),
                  child: Text(
                    widget.stampCard.stampsRatio,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: Utils.basicWidgetEdgeInsets(.5),
                  child: Text('Max: ${widget.stampCard.numMaxStamps}'),
                ),
              ],
            ),
          );
          return SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              margin: Utils.basicScreenEdgeInsets(ctx, constraints),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: Utils.basicWidgetEdgeInsets(1.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        qrImageView,
                        stampsRatioText,
                      ],
                    ),
                  ),
                  Padding(
                    padding: Utils.basicWidgetEdgeInsets(1.5),
                    child: cardInfo,
                  ),
                  Padding(
                    padding: Utils.basicWidgetEdgeInsets(1.5),
                    child: RedeemRulesList(
                      stampCard: widget.stampCard,
                      parentContext: context,
                    ),
                  ),
                  loadableStoreInfo,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static void _onPressLoadStoreInfo() {}
}
