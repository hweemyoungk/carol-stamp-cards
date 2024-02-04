import 'dart:async';
import 'dart:developer' as developer;

import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/params/app.dart' as app_params;
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class RedeemDialogScreen extends ConsumerStatefulWidget {
  final StampCard card;
  final RedeemRule redeemRule;
  const RedeemDialogScreen({
    super.key,
    required this.card,
    required this.redeemRule,
  });

  @override
  ConsumerState<RedeemDialogScreen> createState() => _RedeemDialogScreenState();
}

class _RedeemDialogScreenState extends ConsumerState<RedeemDialogScreen> {
  late Widget redeemButton;
  String? _redeemRequestId;
  late RedeemStatus _redeemStatus;

  @override
  void initState() {
    super.initState();
    final redeemRule = widget.redeemRule;
    final card = widget.card;
    _redeemStatus = card.numCollectedStamps < redeemRule.consumes
        ? RedeemStatus.notRedeemable
        : RedeemStatus.redeemable;
  }

  @override
  Widget build(BuildContext context) {
    final redeemRule = widget.redeemRule;
    final stampCard = widget.card;

    if (_redeemStatus == RedeemStatus.notRedeemable) {
      redeemButton = ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor:
                Theme.of(context).colorScheme.errorContainer),
        child: Text(
          'Not enough stamps!',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      );
    } else if (_redeemStatus == RedeemStatus.redeemable) {
      redeemButton = ElevatedButton(
        onPressed: _onPressRedeem,
        child: Text('Consume ${redeemRule.consumes} stamps to get reward'),
      );
    }

    Widget image = redeemRule.imageUrl == null
        ? Image.memory(
            kTransparentImage,
            fit: BoxFit.contain,
          )
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
            image,
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text(redeemRule.description),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.background),
              onPressed: _onPressBack,
              child: Text(
                'Back',
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
    final stampCard = widget.card;
    final redeemRule = widget.redeemRule;

    // 0. Disable Redeem button.
    setState(() {
      _redeemStatus = RedeemStatus.redeeming;
    });

    // 1. Post RedeemRequest and receive location.
    _redeemRequestId = await _postRedeemRequest(
      stampCardId: stampCard.id,
      redeemRuleId: redeemRule.id,
    );
    if (_redeemRequestId == null) return;
    developer.log('[+]RedeemRequestId: $_redeemRequestId');

    // 2. Watch request exists
    await _watchRedeemRequestExist();

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

        // Get StampCard
        final refreshStampCardTask =
            customer_apis.getStampCard(id: stampCard.id).then((value) {
          // Refresh Card
          cardsNotifier.replaceOrPrepend(value);
        }).onError((error, stackTrace) {
          if (error is Exception) {
            Carol.showExceptionSnackBar(
              error,
              contextMessage:
                  'Failed to refresh card information after redeem.',
            );
          }
        });

        await Future.wait([refreshStampCardTask, DesignUtils.delaySeconds(1)]);
      }

      Carol.showTextSnackBar(
        text: 'Redeem success!',
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
        await DesignUtils.delaySeconds(1);
      }
      Carol.showTextSnackBar(
        text: 'Redeem failed!',
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
        contextMessage: 'Failed to check redeem exists.',
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
              'Awaiting owner\'s approval (${app_params.watchRedeemRequestDurationSeconds - i})',
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
            contextMessage: 'Failed to check redeem request exists.',
          );
        });
      }

      // Wait for one second
      await DesignUtils.delaySeconds(1);
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
            'Sending redeem request to owner...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
        );
      });
    }

    final redeemRequest = RedeemRequest(
      id: -1,
      isDeleted: false,
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
        contextMessage: 'Failed to save new redeem request.',
      );
      return null;
    }
  }

  void _onPressBack() {
    // If redeemRequestId exists, try deleting RedeemRequest
    if (_redeemRequestId != null) {
      customer_apis.deleteRedeemRequest(id: _redeemRequestId!).then((value) {
        if (mounted) {
          setState(() {
            _redeemStatus = RedeemStatus.redeemCanceled;
          });
        }
      }).onError<Exception>((error, stackTrace) {
        Carol.showExceptionSnackBar(
          error,
          contextMessage: 'Failed to cancel redeem request.',
        );
      });
    }
    Navigator.of(context).pop();
  }
}

enum RedeemStatus {
  notRedeemable,
  redeemable,
  redeeming,
  redeemCanceled,
}
