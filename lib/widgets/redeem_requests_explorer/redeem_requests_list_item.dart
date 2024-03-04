import 'package:carol/apis/utils.dart';
import 'package:carol/models/redeem_request.dart';
import 'package:carol/screens/redeem_request_dialog_screen.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RedeemRequestsListItem extends ConsumerStatefulWidget {
  final RedeemRequest redeemRequest;
  const RedeemRequestsListItem({
    super.key,
    required this.redeemRequest,
  });

  @override
  ConsumerState<RedeemRequestsListItem> createState() =>
      _RedeemRequestsListItemState();
}

class _RedeemRequestsListItemState
    extends ConsumerState<RedeemRequestsListItem> {
  late AppLocalizations _localizations;
  late RedeemRequest _redeemRequest;

  @override
  void initState() {
    super.initState();
    _redeemRequest = widget.redeemRequest;
    _notifyEverySecond();
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;

    if (_redeemRequest.redeemRule?.blueprint?.store == null) {
      return ListTile(
        onTap: null,
        leading: const CircularProgressIndicatorInButton(),
        title: Text(_localizations.loadingRedeemRequest),
      );
    }

    var disabled = _redeemRequest.expired || _redeemRequest.isRedeemed;
    final textStyle = TextStyle(
      color: disabled
          ? Theme.of(context).colorScheme.onBackground.withOpacity(0.5)
          : Theme.of(context).colorScheme.onBackground,
    );
    return ListTile(
      onTap: disabled
          ? null
          : () {
              _notifyRedeemRequestDialogScreen();
              showDialog(
                context: context,
                builder: (ctx) {
                  return RedeemRequestDialogScreen(
                    notifyRedeemRequestToParent: _notifyRedeemRequest,
                  );
                },
              );
            },
      leading: Text(
        _redeemRequest.customerDisplayName,
        style: textStyle,
      ),
      title: Text(
        _redeemRequest.redeemRule!.displayName,
        style: textStyle,
      ),
      trailing: _redeemRequest.remainingSecondsWidget,
    );
  }

  /// Notifies <code>ownerRedeemRequestDialogRedeemRequestProvider</code>.
  void _notifyRedeemRequestDialogScreen() {
    final redeemRequestNotifier =
        ref.read(ownerRedeemRequestDialogRedeemRequestProvider.notifier);
    redeemRequestNotifier.set(null);
    redeemRequestNotifier.set(_redeemRequest);
  }

  Future<void> _notifyEverySecond() async {
    while (!_redeemRequest.expired) {
      await Future.delayed(durationOneSecond);
      if (!mounted) return;
      setState(() {});
    }
  }

  void _notifyRedeemRequest(RedeemRequest redeemRequest) {
    if (!mounted) return;
    setState(() {
      _redeemRequest = redeemRequest;
    });
  }
}
