import 'dart:convert';

import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/card_notifier.dart';
import 'package:carol/screens/customer_design_stamp_card_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/card_info.dart';
import 'package:carol/widgets/card/redeem_rules_list.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

final customerCardScreenCardProvider =
    StateNotifierProvider<CardNotifier, StampCard?>(
        (ref) => CardNotifier(null));

class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({
    super.key,
  });

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  var _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(customerCardScreenCardProvider);
    if (card == null) {
      return const Loading(message: 'Loading Card...');
    }
    final blueprint = card.blueprint;
    if (blueprint == null) {
      return const Loading(message: 'Loading Blueprint...');
    }

    final hasNotices = card.isDiscarded || card.isUsedOut;
    final notices = Container(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: DesignUtils.basicWidgetEdgeInsets(),
        child: Column(
          children: [
            if (card.isUsedOut)
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
            if (card.isDiscarded)
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
    final cardInfo = CardInfo(card: card);
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
          final qr = SimpleStampCardQr.fromStampCard(card);
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
                    card.stampsRatio,
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
                          card: card,
                        ),
                      ),
                      storeInfoButton,
                      if (!card.isDiscarded) deleteButton,
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const StoreScreen(),
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
    final stampCard = ref.read(customerCardScreenCardProvider);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CustomerDesignStampCardScreen(
        card: stampCard,
      ),
    ));
  }

  Future<void> _deleteCard() async {
    Navigator.of(context).pop();

    setState(() {
      _isDeleting = true;
    });

    final card = ref.read(customerCardScreenCardProvider);
    if (card == null) return;

    // Soft delete StampCard
    try {
      await customer_apis.softDeleteStampCard(id: card.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to delete card.',
      );
      return;
    }

    final newCard = card.copyWith(
      isDiscarded: true,
      isInactive: true,
    );
    Carol.customerPropagateCard(newCard);

    Carol.showTextSnackBar(
      text: 'Deleted card!',
      level: SnackBarLevel.success,
    );
    setState(() {
      _isDeleting = false;
    });
  }
}
