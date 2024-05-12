import 'dart:async';

import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/params/app.dart' as app_params;
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RedeemDialogScreen extends ConsumerStatefulWidget {
  final StampCard card;
  final RedeemRule redeemRule;
  final void Function(String? redeemRequestId) setRedeemRequestIdToParent;

  const RedeemDialogScreen({
    super.key,
    required this.card,
    required this.redeemRule,
    required this.setRedeemRequestIdToParent,
  });

  @override
  ConsumerState<RedeemDialogScreen> createState() => _RedeemDialogScreenState();
}

class _RedeemDialogScreenState extends ConsumerState<RedeemDialogScreen> {
  late AppLocalizations _localizations;
  late Widget redeemButton;
  String? _redeemRequestId;
  late RedeemStatus _redeemStatus;
  late String _notRedeemableText;

  void _checkRedeemable() {
    final redeemRule = widget.redeemRule;
    final card = widget.card;
    if (card.numCollectedStamps < redeemRule.consumes) {
      _redeemStatus = RedeemStatus.notRedeemable;
      _notRedeemableText = _localizations.notEnoughStamps;
    } else if (card.blueprint!.isExpired) {
      _redeemStatus = RedeemStatus.notRedeemable;
      _notRedeemableText = _localizations.blueprintExpired;
    } else {
      _redeemStatus = RedeemStatus.redeemable;
    }
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    final redeemRule = widget.redeemRule;
    final stampCard = widget.card;

    _checkRedeemable();

    if (_redeemStatus == RedeemStatus.notRedeemable) {
      redeemButton = ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor:
                Theme.of(context).colorScheme.errorContainer),
        child: Text(
          _notRedeemableText,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      );
    } else if (_redeemStatus == RedeemStatus.redeemable) {
      redeemButton = ElevatedButton(
        onPressed: _onPressRedeem,
        child: Text(_localizations.consumeStamps(redeemRule.consumes)),
      );
    }

    Widget? image = redeemRule.imageUrl == null
        // ? Image.memory(
        //     kTransparentImage,
        //     // width: double.infinity,
        //     fit: BoxFit.contain,
        //   )
        ? null
        : Image.asset(
            redeemRule.imageUrl!,
            fit: BoxFit.contain,
          );

    return AlertDialog(
      title: Text(redeemRule.displayName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (image != null) image,
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text(redeemRule.description),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.background),
              onPressed: _onPressBack,
              child: Text(
                _localizations.back,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
            if (!stampCard.isInactive) redeemButton,
          ],
        ),
      ),
    );
  }

  void _onPressRedeem() async {
    final cardsNotifier = ref.read(customerCardsListCardsProvider.notifier);
    final cardNotifier = ref.read(customerCardScreenCardProvider.notifier);
    final oldCard = widget.card;
    final redeemRule = widget.redeemRule;

    // 0. Disable Redeem button.
    setState(() {
      _redeemStatus = RedeemStatus.redeeming;
    });

    // 1. Post RedeemRequest and receive location.
    _redeemRequestId = await _postRedeemRequest(
      stampCardId: oldCard.id,
      redeemRuleId: redeemRule.id,
    );
    if (_redeemRequestId == null) return;
    // developer.log('[+]RedeemRequestId: $_redeemRequestId');

    // Notify to parent(RedeemRuleListItem)
    // Await a second for fade out animation (if any)
    Future.delayed(
      durationOneSecond,
      () {
        if (mounted) {
          // If mounted(still alive), set so that parent try deleting after pop.
          widget.setRedeemRequestIdToParent(_redeemRequestId);
        } else {
          // It not mounted(poped), delete immediately.
          _deleteRedeemRequest(_redeemRequestId!);
        }
      },
    );

    // 2. Watch request exists
    await _watchRedeemRequestExist();

    // RedeemRequest no longer exists. Notify to parent(RedeemRuleListItem)
    // If mounted(still alive), set so that parent try deleting after pop.
    if (mounted) {
      widget.setRedeemRequestIdToParent(null);
    }

    // 3. Check if RedeemHistory exists.
    final hasRedeemHistory = _redeemRequestId == null
        ? false
        : await _redeemHistoryExists(
            redeemRequestId: _redeemRequestId!,
          );

    if (hasRedeemHistory == null) return;

    if (hasRedeemHistory) {
      // 3-1. If exists, redeem succeeded.
      // 3-1.2. Change Progress widget to Completed widget
      if (mounted) {
        setState(() {
          redeemButton = TextButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              Icons.done,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        });
        await Future.delayed(durationOneSecond);
      }
      final newCard = oldCard.copyWith(
        lastModifiedDate: DateTime.now(),
        numCollectedStamps: oldCard.numCollectedStamps - redeemRule.consumes,
      );
      // Propagate
      // customerCardsListCardsProvider
      cardsNotifier.replaceIfIdMatch(newCard);
      // customerStoresListStoresProvider: Not relevant
      // customerCardScreenCardProvider
      cardNotifier.set(newCard);

      Carol.showTextSnackBar(
        text: _localizations.redeemSuccess,
        level: SnackBarLevel.success,
      );
    } else {
      // 3-2. If not, redeem failed. (probably because owner didn't allowed or timeout)
      // 3-2.1. Change Progress with to Refresh widget
      if (mounted) {
        setState(() {
          redeemButton = TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              disabledBackgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.onError,
            ),
          );
        });
        await Future.delayed(durationOneSecond);
      }
      Carol.showTextSnackBar(
        text: _localizations.failedToRedeem,
        level: SnackBarLevel.error,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool?> _redeemHistoryExists({
    required String redeemRequestId,
  }) async {
    if (mounted) {
      setState(() {
        redeemButton = TextButton(
          onPressed: null,
          style: TextButton.styleFrom(
            disabledBackgroundColor:
                Theme.of(context).colorScheme.tertiaryContainer,
          ),
          child: CircularProgressIndicatorInButton(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        );
      });
    }

    try {
      return await customer_apis.redeemExists(redeemRequestId: redeemRequestId);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToCheckRedeemExists,
        localizations: _localizations,
      );
      return null;
    }
  }

  Future<void> _watchRedeemRequestExist() async {
    bool exists = true;
    // Every second...
    for (var i = 0; i < app_params.watchRedeemRequestDurationSeconds; i++) {
      if (_redeemStatus != RedeemStatus.redeeming) return;
      // Check exists
      if (!exists) return;

      if (mounted) {
        setState(() {
          redeemButton = TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              disabledBackgroundColor:
                  Theme.of(context).colorScheme.tertiaryContainer,
            ),
            child: Text(
              '${_localizations.awaitingOwnersApproval} (${app_params.watchRedeemRequestDurationSeconds - i})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          );
        });
      }

      if (_redeemRequestId == null) {
        // Lost redeem request id
        return;
      }

      // Every n seconds...
      if (i % app_params.watchRedeemRequestIntervalSeconds == 0) {
        // Call api
        customer_apis.redeemRequestExists(id: _redeemRequestId!).then(
          (value) {
            if (!value) {
              exists = false;
            }
          },
        ).onError<Exception>((error, stackTrace) {
          Carol.showExceptionSnackBar(
            error,
            contextMessage: _localizations.failedToCheckRedeemRequestExists,
            localizations: _localizations,
          );
        });
      }

      // Wait for one second
      await Future.delayed(durationOneSecond);
    }
  }

  Future<String?> _postRedeemRequest({
    required int stampCardId,
    required int redeemRuleId,
  }) async {
    final currentUser = ref.read(currentUserProvider)!;
    if (mounted) {
      setState(() {
        redeemButton = TextButton(
          onPressed: null,
          style: TextButton.styleFrom(
            disabledBackgroundColor:
                Theme.of(context).colorScheme.tertiaryContainer,
          ),
          child: Text(
            _localizations.sendingRedeemRequest,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
        );
      });
    }

    final redeemRequest = RedeemRequest(
      id: '',
      isDeleted: false,
      displayName: 'Dummy Display Name',
      customerId: currentUser.id,
      customerDisplayName: currentUser.displayName,
      blueprintDisplayName: '',
      expMilliseconds: -1,
      isRedeemed: false,
      redeemRule: null,
      redeemRuleId: redeemRuleId,
      stampCardId: stampCardId,
    );
    try {
      return await customer_apis.postRedeemRequest(
          redeemRequest: redeemRequest);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToSaveNewRedeemRequest,
        localizations: _localizations,
      );
      return null;
    }
  }

  void _onPressBack() {
    // Deleting redeem request will be done in RedeemRuleListItem, after pop.
    Navigator.of(context).pop();
  }

  Future<void> _deleteRedeemRequest(String redeemRequestId) async {
    try {
      await customer_apis.deleteRedeemRequest(id: redeemRequestId);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToCancelRedeemRequest,
        localizations: _localizations,
      );
      return;
    }
  }
}

enum RedeemStatus {
  notRedeemable,
  redeemable,
  redeeming,
  redeemCanceled,
}
