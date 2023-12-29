import 'dart:async';
import 'dart:io';

import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/utils.dart';
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
  String? redeemRequestId;
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
              padding: Utils.basicWidgetEdgeInsets(),
              child: Text(redeemRule.description),
            ),
            TextButton(
              onPressed: _onPressBack,
              child: const Text(
                'Back',
                textAlign: TextAlign.end,
              ),
            ),
            redeemButton,
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
      redeemRequestId = await initRedeemRequest(
        stampCardId: stampCard.id,
        redeemRuleId: redeemRule.id,
      );
    }

    // 2. Every n seconds, check RedeemRequest still exists, until m seconds.
    if (redeemRequestId != null) {
      await watchRedeemRequestNotExist();
    }

    // 3. Check if RedeemHistory exists.
    final hasRedeemHistory = redeemRequestId == null
        ? false
        : await redeemHistoryExists(
            redeemRequestId: redeemRequestId!,
          );
    // 3-1. If exists, redeem succeeded.
    if (hasRedeemHistory) {
      // 3-1.1. Change Progress widget to Completed widget
      if (mounted) {
        _redeemStatus == RedeemStatus.redeemSuccessful;
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
        await Utils.delaySeconds(1);
      }

      // 3-1.2. Close Dialog and refresh CardScreen
      ScaffoldMessenger.of(MyApp.materialKey.currentContext!)
          .showSnackBar(const SnackBar(
        content: Text('Request success'),
        duration: Duration(seconds: 3),
      ));
      final updatedNumCollectedStamps =
          stampCard.numCollectedStamps - redeemRule.consumes;
      final updatedStampCard = stampCard.copyWith(
        numCollectedStamps: updatedNumCollectedStamps,
      );
      stampCardNotifier.set(entity: updatedStampCard);
    } else {
      // 3-2. If not, redeem failed. (probably because owner didn't allowed or timeout)
      // 3-2.1. Change Progress with to Refresh widget
      _redeemStatus == RedeemStatus.redeemFailed;
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
        await Utils.delaySeconds(1);
      }
      ScaffoldMessenger.of(MyApp.materialKey.currentContext!)
          .showSnackBar(const SnackBar(
        content: Text('Request canceled'),
        duration: Duration(seconds: 3),
      ));
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> redeemHistoryExists({
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
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
        );
      });
    }
    final historyExistsTask = Future(() async {
      await Future.delayed(Duration(seconds: random.nextInt(3) + 1));
      final exists = random.nextDouble() < 0.5;
      return exists;
    });
    return historyExistsTask;
  }

  Future<void> watchRedeemRequestNotExist() async {
    const totalSeconds = 20;
    const checkIntervalSeconds = 3;
    Future<bool> requestExistsTask;
    Completer<bool> completer = Completer<bool>();
    for (var i = 0; i < totalSeconds; i++) {
      if (_redeemStatus != RedeemStatus.redeeming) return;

      if (mounted) {
        setState(() {
          redeemButton = TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              disabledBackgroundColor:
                  Theme.of(context).colorScheme.tertiaryContainer,
            ),
            child: Text(
              'Awaiting owner\'s approval (${totalSeconds - i})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          );
        });
      }

      // check RedeemRequest still exists
      if (i % checkIntervalSeconds == 0) {
        // requestExistsTask = http.get('foo');
        requestExistsTask = Future(() async {
          final localCompleter = Completer<bool>();
          localCompleter.future.catchError((e) {
            print(e);
            return false;
          });
          completer = localCompleter;
          await Future.delayed(Duration(seconds: random.nextInt(5) + 1));
          if (random.nextDouble() < 0.1) {
            final error =
                HttpException('RequestExists at t=${i}s threw error!');
            localCompleter.completeError(error);
            return Future.error(error);
          }
          final exists = random.nextDouble() < 0.0;
          print('RequestExists at t=${i}s responds: $exists');
          localCompleter.complete(exists);
          return exists;
        });
        requestExistsTask.catchError((e) {
          print(e);
          return false;
        });
      }
      await Utils.delaySeconds(1);
      if (completer.isCompleted) {
        try {
          final exists = await completer.future;
          // 2-1. If not exist, break.
          if (!exists) {
            break;
          }
        } catch (e) {
          print('caught error from future: ${e.toString()}');
        }
      }
    }
  }

  Future<String> initRedeemRequest({
    required String stampCardId,
    required String redeemRuleId,
  }) async {
    if (mounted) {
      setState(() {
        redeemButton = TextButton(
          onPressed: null,
          style: TextButton.styleFrom(
            disabledBackgroundColor:
                Theme.of(context).colorScheme.tertiaryContainer,
          ),
          child: Text(
            'Sending a reward request to owner...',
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
    // 4. Create new RedeemRequest: resource.postRedeemRequest()
    // 5. return redeemRequestId
    await Future.delayed(Duration(seconds: 1));
    return uuid.v4();
  }

  void _onPressBack() {
    // If redeemRequestId exists, try deleting RedeemRequest
    if (redeemRequestId != null) {
      Future.delayed(
        const Duration(seconds: 2),
        () {
          return random.nextDouble() < 0.5;
        },
      ).then((deleted) {
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
  redeemFailed,
  redeemSuccessful,
}
