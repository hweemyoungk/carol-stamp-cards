import 'dart:convert';

import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/screens/customer_design_stamp_card_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/card_info.dart';
import 'package:carol/widgets/card/redeem_rules_list.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
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
  var _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final stampCard = ref.watch(widget.stampCardProvider);
    final blueprint = ref.watch(widget.blueprintProvider);

    final hasNotices = stampCard.isDiscarded || stampCard.isUsedOut;
    final notices = Container(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: DesignUtils.basicWidgetEdgeInsets(),
        child: Column(
          children: [
            if (stampCard.isUsedOut)
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
            if (stampCard.isDiscarded)
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
        disabledBackgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
      onPressed: _isDeleting ? null : _onPressDeleteCard,
      icon: Icon(
        Icons.delete,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
      label: _isDeleting
          ? CircularProgressIndicatorInButton(
              color: Theme.of(context).colorScheme.onErrorContainer)
          : Text(
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
          final qr = SimpleStampCardQr.fromStampCard(stampCard);
          final qrImageView = QrImageView(
            data: json.encode(qr.toJson()),
            version: QrVersions.auto,
            size: constraints.maxWidth * 0.4,
          );
          final stampsRatioText = SizedBox(
            width: constraints.maxWidth * 0.4,
            child: Column(
              children: [
                Padding(
                  padding: DesignUtils.basicWidgetEdgeInsets(.5),
                  child: Text(
                    stampCard.stampsRatio,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: DesignUtils.basicWidgetEdgeInsets(.5),
                  child: Text(
                    'Max: ${blueprint.numMaxStamps}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
          return SingleChildScrollView(
            child: Column(
              children: [
                if (hasNotices) notices,
                Container(
                  alignment: Alignment.center,
                  margin: DesignUtils.basicScreenEdgeInsets(ctx, constraints),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: DesignUtils.basicWidgetEdgeInsets(1.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            qrImageView,
                            stampsRatioText,
                          ],
                        ),
                      ),
                      Padding(
                        padding: DesignUtils.basicWidgetEdgeInsets(1.5),
                        child: cardInfo,
                      ),
                      Padding(
                        padding: DesignUtils.basicWidgetEdgeInsets(1.5),
                        child: RedeemRulesList(
                          stampCardProvider: widget.stampCardProvider,
                          blueprintProvider: widget.blueprintProvider,
                        ),
                      ),
                      storeInfoButton,
                      if (!stampCard.isDiscarded) deleteButton,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onPressLoadStoreInfo() async {
    final stampCard = ref.read(widget.stampCardProvider);
    final storeProvider = customerStoreProviders.tryGetProviderById(
        id: await stampCard.blueprint.then((value) => value.storeId))!;
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => StoreScreen(storeProvider: storeProvider),
      ));
    }
  }

  void _onPressDeleteCard() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
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
              padding: DesignUtils.basicWidgetEdgeInsets(),
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
    final stampCard = ref.read(widget.stampCardProvider);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CustomerDesignStampCardScreen(
        stampCard: stampCard,
        blueprintProvider: widget.blueprintProvider,
      ),
    ));
  }

  Future<void> _deleteCard() async {
    if (mounted) {
      Navigator.of(context).pop();
    }
    setState(() {
      _isDeleting = true;
    });

    final stampCard = ref.read(widget.stampCardProvider);
    final stampCardNotifier = ref.read(widget.stampCardProvider.notifier);

    // Soft delete StampCard
    // await DesignUtils.delaySeconds(2);
    // stampCardNotifier.set(
    //   entity: stampCard.copyWith(
    //     wasDiscarded: true,
    //     isInactive: true,
    //   ),
    // );
    try {
      await customer_apis.softDeleteStampCard(id: stampCard.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to delete card.',
      );
    }

    stampCardNotifier.dispose();

    Carol.showTextSnackBar(
      text: 'Deleted card!',
      level: SnackBarLevel.success,
    );
    setState(() {
      _isDeleting = false;
    });
  }
}
