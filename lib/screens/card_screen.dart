import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/card_info.dart';
import 'package:carol/widgets/card/redeem_rules_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CardScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<EntityStateNotifier<StampCard>, StampCard>
      stampCardProvider;
  const CardScreen({
    super.key,
    required this.stampCardProvider,
  });

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  final loadableStoreInfo = ElevatedButton.icon(
    onPressed: _onPressLoadStoreInfo,
    icon: const Icon(Icons.store),
    label: const Text('Store Info'),
  );

  @override
  Widget build(BuildContext context) {
    final stampCard = ref.watch(widget.stampCardProvider);
    final cardInfo = CardInfo(stampCardProvider: widget.stampCardProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final qrImageView = QrImageView(
            data: stampCard.id,
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
                    stampCard.stampsRatio,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: Utils.basicWidgetEdgeInsets(.5),
                  child: Text(
                    'Max: ${stampCard.numMaxStamps}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
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
                      stampCardProvider: widget.stampCardProvider,
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
