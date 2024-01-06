import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/card_info.dart';
import 'package:carol/widgets/card/redeem_rules_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CardScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<EntityStateNotifier<StampCard>, StampCard>
      stampCardProvider;
  final StateNotifierProvider<EntityStateNotifier<StampCardBlueprint>,
      StampCardBlueprint> blueprintProvider;
  const CardScreen({
    super.key,
    required this.stampCardProvider,
    required this.blueprintProvider,
  });

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  @override
  Widget build(BuildContext context) {
    final stampCard = ref.watch(widget.stampCardProvider);

    final hasNotices = stampCard.wasDiscarded || stampCard.wasUsedOut;
    final notices = Container(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: Utils.basicWidgetEdgeInsets(),
        child: Column(
          children: [
            if (stampCard.wasUsedOut)
              Row(
                children: [
                  Icon(Icons.warning,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Card had been Used Out.',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                ],
              ),
            if (stampCard.wasDiscarded)
              Row(
                children: [
                  Icon(Icons.warning,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Card was already DELETED.',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    final storeInfoButton = ElevatedButton.icon(
      onPressed: _onPressLoadStoreInfo,
      icon: const Icon(Icons.store),
      label: const Text('Store Info'),
    );
    final deleteButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
      onPressed: _onPressDeleteCard,
      icon: Icon(
        Icons.delete,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
      label: Text(
        'Delete Card',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );
    final cardInfo = CardInfo(stampCardProvider: widget.stampCardProvider);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _onPressModifyCard,
            icon: const Icon(Icons.construction),
          ),
        ],
      ),
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
                  if (hasNotices) notices,
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
                      blueprintProvider: widget.blueprintProvider,
                    ),
                  ),
                  storeInfoButton,
                  if (!stampCard.wasDiscarded) deleteButton,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onPressLoadStoreInfo() {
    final stampCard = ref.read(widget.stampCardProvider);
    final storeProvider =
        customerStoreProviders.tryGetProviderById(id: stampCard.storeId)!;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => StoreScreen(storeProvider: storeProvider),
    ));
  }

  void _onPressDeleteCard() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: Utils.basicWidgetEdgeInsets(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Delete this card?',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: Utils.basicWidgetEdgeInsets(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.background),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                      ),
                      onPressed: _deleteCard,
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      )),
                ],
              ),
            ),
          ],
        );
      },
      useSafeArea: true,
    );
  }

  void _onPressModifyCard() {
    // TODO Implement
  }

  Future<void> _deleteCard() async {
    final stampCard = ref.read(widget.stampCardProvider);
    final stampCardNotifier = ref.read(widget.stampCardProvider.notifier);
    // TODO Implement
    // apis.softDeleteStampCard(stampCardId: stampCard.id);
    await Utils.delaySeconds(2);
    stampCardNotifier.set(
        entity: stampCard.copyWith(
      wasDiscarded: true,
      isInactive: true,
    ));
  }
}
