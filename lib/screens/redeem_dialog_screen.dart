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
  bool redeeming = false;
  late Widget redeemButton;
  String? redeemRequestId;

  @override
  Widget build(BuildContext context) {
    final stampCard = ref.watch(widget.stampCardProvider);
    final redeemRule = ref.watch(widget.redeemRuleProvider);

    redeemButton = stampCard.numCollectedStamps < redeemRule.consumes
        // Very rare case
        ? ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
                disabledBackgroundColor:
                    Theme.of(context).colorScheme.errorContainer),
            child: Text(
              'Not enough stamps!',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          )
        // 99% likely case
        : ElevatedButton(
            onPressed: _onPressRedeem,
            child: Text('Consume ${redeemRule.consumes} stamps to get reward'),
          );

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
      redeeming = true;
    });

    // 1. Post RedeemRequest and receive location.
    // Trigger customerService.initRedeemRequest
    if (redeeming) {
      redeemRequestId = await initRedeemRequest(
        stampCardId: stampCard.id,
        redeemRuleId: redeemRule.id,
      );
    }

    // 2. Every n seconds, check RedeemRequest still exists, until m seconds.
    if (redeeming) {
      await watchRedeemRequestNotExist();
    }

    // 3. Check if RedeemHistory exists.
    final hasRedeemHistory = await redeemHistoryExists(
      redeemRequestId: redeemRequestId!,
    );
    // 3-1. If exists, redeem succeeded.
    if (hasRedeemHistory) {
      // 3-1.1. Change Progress widget to Completed widget
      if (mounted) {
        setState(() {
          redeemButton = TextButton(
            onPressed: null,
            child: Icon(
              Icons.done,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        });
        await Future.delayed(Duration(seconds: 1));
      }

      // 3-1.2. Close Dialog and refresh CardScreen
      ScaffoldMessenger.of(MyApp.materialKey.currentContext!).clearSnackBars();
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
      if (mounted) {
        setState(() {
          redeemButton = TextButton(
            onPressed: null,
            child: Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        });
        await Future.delayed(Duration(seconds: 1));
      }
      ScaffoldMessenger.of(MyApp.materialKey.currentContext!).clearSnackBars();
      ScaffoldMessenger.of(MyApp.materialKey.currentContext!)
          .showSnackBar(const SnackBar(
        content: Text('Request canceled'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Future<bool> redeemHistoryExists({
    required String redeemRequestId,
  }) async {
    if (mounted) {
      setState(() {
        redeemButton = const TextButton(
          onPressed: null,
          child: CircularProgressIndicator(),
        );
      });
    }
    final historyExistsTask = Future(() async {
      // sleep(Duration(seconds: random.nextInt(5) + 1));
      await Future.delayed(Duration(seconds: random.nextInt(5) + 1));
      final exists = random.nextDouble() < 1.0;
      return exists;
    });
    return await historyExistsTask;
  }

  Future<void> watchRedeemRequestNotExist() async {
    const totalSeconds = 20;
    const checkIntervalSeconds = 3;
    Future<bool> requestExistsTask;
    Completer<bool> completer = Completer<bool>();
    for (var i = 0; i < totalSeconds; i++) {
      if (!redeeming) return;

      if (mounted) {
        setState(() {
          redeemButton = TextButton(
            onPressed: null,
            child: Text(
              'Awaiting owner\'s approval (${totalSeconds - i})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
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
      await Future.delayed(Duration(seconds: 1));
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
          child: Text(
            'Sending a reward request to owner...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
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
    setState(() {
      redeeming = false;
    });

    // If redeemRequestId exists, try deleting RedeemRequest
    if (redeemRequestId != null) {
      Future.delayed(
        Duration(seconds: 2),
        () {
          print('RedeemRequest deleted!');
        },
      );
      redeemRequestId = null;
    }
    Navigator.of(context).pop();
  }
}
