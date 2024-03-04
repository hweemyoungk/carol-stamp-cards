import 'dart:convert';

import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/card_notifier.dart';
import 'package:carol/screens/customer_design_stamp_card_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/card/card_info.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:carol/widgets/redeem_rules_explorer/redeem_rules_list.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  late AppLocalizations _localizations;
  var _isDeleting = false;
  var _isRefreshCooling = false;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    final watchedCard = ref.watch(customerCardScreenCardProvider);
    if (watchedCard?.blueprint?.redeemRules == null) {
      return Loading(message: _localizations.loadingCard);
    }

    final card = watchedCard!;
    final blueprint = card.blueprint!;
    final isStoreDeleted = card.blueprint?.store == null;

    final hasNotices = card.isDiscarded ||
        card.isUsedOut ||
        blueprint.isExpired ||
        isStoreDeleted;
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
                    _localizations.reachedMaxNumRedeems,
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
                    _localizations.alreadyDeletedCard,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                ],
              ),
            if (blueprint.isExpired)
              Row(
                children: [
                  Icon(Icons.warning,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    _localizations.alreadyExpiredCard,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                ],
              ),
            if (isStoreDeleted)
              Row(
                children: [
                  Icon(Icons.warning,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    _localizations.alreadyDeletedStore,
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        disabledBackgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.5),
      ),
      onPressed: isStoreDeleted ? null : _onPressStoreInfo,
      icon: Icon(
        Icons.store,
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(
              isStoreDeleted ? 0.5 : 1.0,
            ),
      ),
      label: Text(
        _localizations.storeInfo,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(
                isStoreDeleted ? 0.5 : 1.0,
              ),
        ),
      ),
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
              _localizations.deleteCard,
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
          _isRefreshCooling
              ? const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.refresh),
                )
              : IconButton(
                  onPressed: _onPressRefreshCard,
                  icon: const Icon(Icons.refresh),
                ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final qr = SimpleCardQr.fromStampCard(card);
          final qrImageView = QrImageView(
            data: base64.encode(json.encode(qr.toJson()).codeUnits),
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
                    '${_localizations.max}: ${blueprint.numMaxStamps}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
          final redeemRules = card.blueprint?.redeemRules?.toList();
          redeemRules?.sort(
            (a, b) => a.consumes - b.consumes,
          );
          return SingleChildScrollView(
            child: Column(
              children: [
                if (hasNotices) notices,
                Container(
                  alignment: Alignment.center,
                  margin:
                      DesignUtils.basicScreenEdgeInsets(ctx, constraints, 0.5),
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
                      if (redeemRules != null)
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(1.5),
                          child: RedeemRulesList(
                            redeemRules: redeemRules,
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

  void _onPressStoreInfo() {
    _notifyStoreScreen();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const StoreScreen(),
    ));
  }

  /// Notifies <code>customerStoreScreenStoreProvider</code>.
  Future<void> _notifyStoreScreen() async {
    final storeNotifier = ref.read(customerStoreScreenStoreProvider.notifier);
    final storesNotifier = ref.read(customerStoresListStoresProvider.notifier);
    storeNotifier.set(null);

    final card = ref.read(customerCardScreenCardProvider);
    if (card == null) {
      return;
    }

    if (card.blueprint?.store == null) {
      // Ignore store == null scenario: many-to-one
      // Ignore blueprint == null scenario: many-to-one
      Carol.showTextSnackBar(
        text: _localizations.lostData,
        level: SnackBarLevel.warn,
      );
      return;
    }

    // Store needs blueprints
    final store = card.blueprint!.store!;
    if (store.blueprints != null) {
      storeNotifier.set(store);
      return;
    }

    final Set<Blueprint> blueprints;
    try {
      blueprints = await customer_apis.listBlueprints(storeId: store.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToLoadBlueprints,
        localizations: _localizations,
      );
      return;
    }
    final newStore = store.copyWith(blueprints: blueprints);

    // Propagate
    // customerCardsListCardsProvider: Not relevant
    // customerStoresListStoresProvider
    storesNotifier.replaceOrPrepend(newStore);
    // customerCardScreenCardProvider: Not relevant

    storeNotifier.set(newStore);
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
                  Column(
                    children: [
                      Text(
                        _localizations.deleteCardAlertTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                      Text(
                        _localizations.alertContentCannotUndo,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ],
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
                      _localizations.back,
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
                        _localizations.delete,
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
    final card = ref.read(customerCardScreenCardProvider);

    _notifyCustomerDesignStampCardScreen();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CustomerDesignStampCardScreen(
        card: card,
      ),
    ));
  }

  /// Notifies <code>customerDesignCardScreenBlueprintProvider</code>.
  Future<void> _notifyCustomerDesignStampCardScreen() async {
    final blueprintNotifier =
        ref.read(customerDesignCardScreenBlueprintProvider.notifier);
    blueprintNotifier.set(null);

    final card = ref.read(customerCardScreenCardProvider);
    if (card == null) {
      return;
    }

    if (card.blueprint == null) {
      // Ignore blueprint == null scenario: many-to-one
      Carol.showTextSnackBar(
        text: _localizations.lostData,
        level: SnackBarLevel.warn,
      );
      return;
    }

    blueprintNotifier.set(card.blueprint);
    return;
  }

  Future<void> _deleteCard() async {
    final cardsNotifier = ref.read(customerCardsListCardsProvider.notifier);
    final cardNotifier = ref.read(customerCardScreenCardProvider.notifier);

    Navigator.of(context).pop();

    setState(() {
      _isDeleting = true;
    });

    final card = ref.read(customerCardScreenCardProvider);
    if (card == null) return;

    // Discard StampCard
    try {
      await customer_apis.discardStampCard(id: card.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToDeleteCard,
        localizations: _localizations,
      );
      return;
    }

    final deletedCard = card.copyWith(
      isDiscarded: true,
      isInactive: true,
    );

    // Propagate
    // customerCardsListCardsProvider
    cardsNotifier.replaceIfIdMatch(deletedCard);
    // customerStoresListStoresProvider: Not relavent
    // customerCardScreenCardProvider
    cardNotifier.set(deletedCard);

    Carol.showTextSnackBar(
      text: _localizations.deleteCardSuccess,
      level: SnackBarLevel.success,
    );

    setState(() {
      _isDeleting = false;
    });
  }

  Future<void> _onPressRefreshCard() async {
    _setRefreshCooling();

    final oldCard = ref.read(customerCardScreenCardProvider);
    if (oldCard == null) {
      return;
    }

    final cardNotifier = ref.read(customerCardScreenCardProvider.notifier);
    final cardsNotifier = ref.read(customerCardsListCardsProvider.notifier);
    final storesNotifier = ref.read(customerStoresListStoresProvider.notifier);

    StampCard fetchedCard;
    try {
      fetchedCard = await customer_apis.getStampCard(id: oldCard.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToLoadCard,
        localizations: _localizations,
      );
      return;
    }

    var fetchedBlueprint = fetchedCard.blueprint;
    if (fetchedBlueprint == null) {
      Carol.showTextSnackBar(
        text: _localizations.failedToLoadBlueprint,
        level: SnackBarLevel.error,
      );
      return;
    }

    if (fetchedBlueprint.redeemRules == null) {
      // Try fetch redeemRules
      Set<RedeemRule> fetchedRedeemRules;
      try {
        fetchedRedeemRules = await customer_apis.listRedeemRules(
          blueprintId: fetchedBlueprint.id,
        );
      } on Exception {
        // Attach old redeemRules
        fetchedRedeemRules = oldCard.blueprint!.redeemRules!;
      }
      fetchedBlueprint = fetchedBlueprint.copyWith(
        redeemRules: fetchedRedeemRules,
      );
      fetchedCard = fetchedCard.copyWith(blueprint: fetchedBlueprint);
    }

    // Propagate
    // customerCardsListCardsProvider
    cardsNotifier.replaceIfIdMatch(fetchedCard);
    // customerStoresListStoresProvider
    final fetchedStore = fetchedCard.blueprint?.store;
    if (fetchedStore != null) {
      storesNotifier.replaceOrPrepend(fetchedStore);
    }
    // customerCardScreenCardProvider
    cardNotifier.set(fetchedCard);
  }

  Future<void> _setRefreshCooling() async {
    if (!mounted) return;
    setState(() {
      _isRefreshCooling = true;
    });
    await Future.delayed(refreshCoolingDuration);
    if (!mounted) return;
    setState(() {
      _isRefreshCooling = false;
    });
  }
}
