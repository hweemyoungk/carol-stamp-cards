import 'package:carol/apis/owner_apis.dart';
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/providers/redeem_request_notifier.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final ownerRedeemRequestDialogRedeemRequestProvider =
    StateNotifierProvider<RedeemRequestNotifier, RedeemRequest?>(
        (ref) => RedeemRequestNotifier(null));

class RedeemRequestDialogScreen extends ConsumerStatefulWidget {
  final void Function(RedeemRequest redeemRequest) notifyRedeemRequestToParent;
  const RedeemRequestDialogScreen({
    super.key,
    required this.notifyRedeemRequestToParent,
  });

  @override
  ConsumerState<RedeemRequestDialogScreen> createState() =>
      _RedeemRequestDialogScreenState();
}

class _RedeemRequestDialogScreenState
    extends ConsumerState<RedeemRequestDialogScreen> {
  late AppLocalizations _localizations;
  ApprovalStatus _status = ApprovalStatus.notApprovable;
  String? _notApprovableReason;

  void _checkApprovable(RedeemRequest redeemRequest) {
    // redeem request expired?
    if (redeemRequest.expired) {
      _notApprovableReason = _localizations.requestAlreadyExpired;
      return;
    }

    // redeem request already redeemed?
    if (redeemRequest.isRedeemed) {
      _notApprovableReason = _localizations.alreadyRedeemed;
      return;
    }

    // blueprint expired?
    if (redeemRequest.redeemRule!.blueprint!.isExpired) {
      _notApprovableReason = _localizations.blueprintExpired;
      return;
    }

    _status = ApprovalStatus.approvable;
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    var redeemRequest =
        ref.watch(ownerRedeemRequestDialogRedeemRequestProvider);

    if (redeemRequest?.redeemRule?.blueprint?.store == null) {
      return Loading(
        message: _localizations.loadingRedeemRequest,
      );
    }

    redeemRequest = redeemRequest!;
    _checkApprovable(redeemRequest);

    final redeemRule = redeemRequest.redeemRule!;
    final blueprint = redeemRule.blueprint!;
    final store = blueprint.store!;
    Widget? image = redeemRule.imageUrl == null
        // ? Image.memory(
        //     kTransparentImage,
        //     fit: BoxFit.contain,
        //   )
        ? null
        : Image.asset(
            redeemRule.imageUrl!,
            fit: BoxFit.contain,
          );

    return AlertDialog(
      title: Text(_localizations.customerDisplayNamesRedeemRequest(
          redeemRequest.customerDisplayName)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (image != null) image,
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text(
                _localizations.consumesStampsBy(redeemRule.consumes),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Column(
                children: [
                  Padding(
                    padding: DesignUtils.basicWidgetEdgeInsets(),
                    child: Text(
                      redeemRule.displayName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Text(
                    redeemRule.description,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text(
                _localizations.blueprint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              blueprint.displayName,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text(
                _localizations.store,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              store.displayName,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: _approveButton,
            ),
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
        child: Text(_notApprovableReason ?? _localizations.cannotApprove),
      );
    } else if (_status == ApprovalStatus.approvable) {
      return ElevatedButton(
        onPressed: _onPressApprove,
        child: Text(_localizations.approve),
      );
    } else if (_status == ApprovalStatus.approving) {
      return ElevatedButton(
        onPressed: null,
        style: TextButton.styleFrom(
          disabledBackgroundColor:
              Theme.of(context).colorScheme.tertiaryContainer,
        ),
        child: Text(
          _localizations.approving,
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
    final redeemRequest =
        ref.read(ownerRedeemRequestDialogRedeemRequestProvider);
    if (redeemRequest == null) {
      return;
    }

    try {
      await approveRedeemRequest(redeemRequestId: redeemRequest.id);
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _status = ApprovalStatus.approveFailed;
        });
      }
      await Future.delayed(durationOneSecond);
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToApproveRedeemRequest,
        localizations: _localizations,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    }

    widget.notifyRedeemRequestToParent(
      redeemRequest.copyWith(isRedeemed: true),
    );

    if (mounted) {
      setState(() {
        _status = ApprovalStatus.approveSuccessful;
      });
    }
    await Future.delayed(durationOneSecond);
    Carol.showTextSnackBar(
      text: _localizations.approveSuccess,
      level: SnackBarLevel.success,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

enum ApprovalStatus {
  notApprovable,
  approvable,
  approving,
  approveSuccessful,
  approveFailed,
}
