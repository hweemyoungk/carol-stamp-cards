import 'dart:async';

import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/params/app.dart' as app_params;
import 'package:carol/providers/current_user_provider.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class RedeemDialogScreen extends ConsumerStatefulWidget {
  const RedeemDialogScreen({
    super.key,
    required this.stampCardProvider,
    required this.redeemRuleProvider,
  });

  final StateNotifierProvider<EntityStateNotifier<StampCard>, StampCard>
      stampCardProvider;
  final StateNotifierProvider<EntityStateNotifier<RedeemRule>, RedeemRule>
      redeemRuleProvider;

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
    final redeemRule = ref.read(widget.redeemRuleProvider);
    final stampCard = ref.read(widget.stampCardProvider);
    _redeemStatus = stampCard.numCollectedStamps < redeemRule.consumes
        ? RedeemStatus.notRedeemable
        : RedeemStatus.redeemable;
  }

  @override
  Widget build(BuildContext context) {
    final redeemRule = ref.watch(widget.redeemRuleProvider);
    final stampCard = ref.watch(widget.stampCardProvider);

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
    final stampCard = ref.read(widget.stampCardProvider);
    final stampCardNotifier = ref.read(widget.stampCardProvider.notifier);
    final redeemRule = ref.read(widget.redeemRuleProvider);

    // 0. Disable Redeem button.
    setState(() {
      _redeemStatus = RedeemStatus.redeeming;
    });

    // 1. Post RedeemRequest and receive location.
    // Trigger customerService.initRedeemRequest
    if (_redeemStatus == RedeemStatus.redeeming) {
      _redeemRequestId = await _postRedeemRequest(
        stampCardId: stampCard.id,
        redeemRuleId: redeemRule.id,
      );
    }

    // 2. Watch request exists
    await _watchRedeemRequestExist();

    // 3. Check if RedeemHistory exists.
    final hasRedeemHistory = _redeemRequestId == null
        ? false
        : await _redeemHistoryExists(
            redeemRequestId: _redeemRequestId!,
          );

    if (hasRedeemHistory) {
      // 3-1. If exists, redeem succeeded.
      // 3-1.1. Close Dialog and refresh CardScreen
      // final updatedNumCollectedStamps =
      //     stampCard.numCollectedStamps - redeemRule.consumes;
      // final updatedStampCard = stampCard.copyWith(
      //   numCollectedStamps: updatedNumCollectedStamps,
      // );
      // stampCardNotifier.set(entity: updatedStampCard);
      // Get StampCard

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
        final refreshStampCardTask =
            customer_apis.getStampCard(id: stampCard.id).then((value) {
          stampCardNotifier.set(entity: value);
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

  Future<bool> _redeemHistoryExists({
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

    // final historyExistsTask = Future(() async {
    //   await Future.delayed(Duration(seconds: random.nextInt(3) + 1));
    //   final exists = random.nextDouble() < 0.5;
    //   return exists;
    // });
    final historyExists =
        await customer_apis.redeemExists(redeemRequestId: redeemRequestId);
    return historyExists;
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

      // Every n seconds...
      if (i % app_params.watchRedeemRequestIntervalSeconds == 0) {
        // Call api
        customer_apis.redeemRequestExists(id: _redeemRequestId!).then(
          (value) {
            if (!value) {
              exists = false;
            }
          },
        );
      }

      // Wait for one second
      await DesignUtils.delaySeconds(1);
    }
  }

  Future<String> _postRedeemRequest({
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

    // customerService.initRedeemRequest
    // 1. Check card exists: card = resource.getCard(cardId)
    // 2. Check redeemRule exists: redeemRule = resource.getRedeemRule(redeemRuleId)
    // 3. Check same BP: card.getBP() == redeemRule.getBP()
    // 3.5 Check BP has this redeemRule: redeemRule in resource.getCard(cardId).getBP().getRedeemRules()
    // 4. Create new RedeemRequest: resource.postRedeemRequest()
    // 5. return redeemRequestId
    // 1~3.5 will be done in server-side.
    // await Future.delayed(Duration(seconds: 1));
    // return uuid.v4();
    final redeemRequest = RedeemRequest(
      id: '',
      customerId: currentUser.id,
      customerDisplayName: currentUser.displayName,
      stampCardId: stampCardId,
      redeemRuleId: redeemRuleId,
      blueprintDisplayName: '',
      ttlMilliseconds: app_params.watchRedeemRequestDurationSeconds * 1000,
      isRedeemed: false,
    );
    final redeemRequestId =
        await customer_apis.postRedeemRequest(redeemRequest: redeemRequest);
    return redeemRequestId;
  }

  void _onPressBack() {
    // If redeemRequestId exists, try deleting RedeemRequest
    if (_redeemRequestId != null) {
      customer_apis
          .deleteRedeemRequest(
        id: _redeemRequestId!,
      )
          .then((value) {
        if (mounted) {
          setState(() {
            _redeemStatus = RedeemStatus.redeemCanceled;
          });
        }
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
