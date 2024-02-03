import 'package:carol/apis/owner_apis.dart';
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class RedeemRequestDialogScreen extends ConsumerStatefulWidget {
  final RedeemRequest redeemRequest;
  final StateNotifierProvider<EntityStateNotifier<Store>, Store> storeProvider;
  final StateNotifierProvider<EntityStateNotifier<Blueprint>, Blueprint>
      blueprintProvider;
  final StateNotifierProvider<EntityStateNotifier<RedeemRule>, RedeemRule>
      redeemRuleProvider;
  const RedeemRequestDialogScreen({
    super.key,
    required this.storeProvider,
    required this.blueprintProvider,
    required this.redeemRequest,
    required this.redeemRuleProvider,
  });

  @override
  ConsumerState<RedeemRequestDialogScreen> createState() =>
      _RedeemRequestDialogScreenState();
}

class _RedeemRequestDialogScreenState
    extends ConsumerState<RedeemRequestDialogScreen> {
  ApprovalStatus _status = ApprovalStatus.notApprovable;
  String? _notApprovableReason;

  @override
  void initState() {
    super.initState();

    _checkApprovable();
  }

  void _checkApprovable() {
    setState(() {
      // redeem request expired?
      if (widget.redeemRequest.expired) {
        _notApprovableReason = 'Request already expired';
        return;
      }

      // redeem request already redeemed?
      if (widget.redeemRequest.isRedeemed) {
        _notApprovableReason = 'Already redeemed';
        return;
      }

      // blueprint expired?
      if (ref.read(widget.blueprintProvider).isExpired) {
        _notApprovableReason = 'Blueprint already expired';
        return;
      }

      _status = ApprovalStatus.approvable;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(widget.storeProvider);
    final blueprint = ref.watch(widget.blueprintProvider);
    final redeemRule = ref.watch(widget.redeemRuleProvider);
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
      title:
          Text('${widget.redeemRequest.customerDisplayName}\'s Redeem Request'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            image,
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text('Consumes ${redeemRule.consumes} stamps by'),
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text(redeemRule.displayName),
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text(redeemRule.description),
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text('of ${blueprint.displayName}'),
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text('of ${store.displayName}'),
            ),
            _approveButton,
          ],
        ),
      ),
    );
  }

  Widget get _approveButton {
    if (_status == ApprovalStatus.notApprovable) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor:
                Theme.of(context).colorScheme.errorContainer),
        child: Text(_notApprovableReason ?? 'Cannot approve'),
      );
    } else if (_status == ApprovalStatus.approvable) {
      return ElevatedButton(
        onPressed: _onPressApprove,
        child: const Text('Approve'),
      );
    } else if (_status == ApprovalStatus.approving) {
      return ElevatedButton(
        onPressed: null,
        style: TextButton.styleFrom(
          disabledBackgroundColor:
              Theme.of(context).colorScheme.tertiaryContainer,
        ),
        child: Text(
          'Approving',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
      );
    } else if (_status == ApprovalStatus.approveFailed) {
      return TextButton(
        onPressed: null,
        style: TextButton.styleFrom(
          disabledBackgroundColor: Theme.of(context).colorScheme.error,
        ),
        child: Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.onError,
        ),
      );
    } else {
      // ApprovalStatus.approveSuccessful
      return TextButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(
          Icons.done,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
  }

  Future<void> _onPressApprove() async {
    try {
      await approveRedeemRequest(redeemRequestId: widget.redeemRequest.id);
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _status = ApprovalStatus.approveFailed;
        });
      }
      await Future.delayed(durationOneSecond);
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to approve redeem request.',
      );
      return;
    }

    if (mounted) {
      setState(() {
        _status = ApprovalStatus.approveSuccessful;
      });
    }
    await Future.delayed(durationOneSecond);
    Carol.showTextSnackBar(
      text: 'Approved redeem request!',
      level: SnackBarLevel.success,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
    return;
  }
}

enum ApprovalStatus {
  notApprovable,
  approvable,
  approving,
  approveSuccessful,
  approveFailed,
}
