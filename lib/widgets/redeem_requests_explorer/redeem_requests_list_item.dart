import 'package:carol/models/redeem_request.dart';
import 'package:carol/screens/redeem_request_dialog_screen.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  Widget build(BuildContext context) {
    final redeemRequest = widget.redeemRequest;
    if (redeemRequest.redeemRule?.blueprint?.store == null) {
      return const Loading(message: 'Loading redeem request...');
    }
    return ListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) {
            _notifyRedeemRequestDialogScreen();
            return const RedeemRequestDialogScreen();
          },
        );
      },
      leading: Text(redeemRequest.customerDisplayName),
      title: Text(redeemRequest.redeemRule!.displayName),
      trailing: redeemRequest.remainingSecondsWidget,
    );
  }

  /// Notifies <code>ownerRedeemRequestDialogRedeemRequestProvider</code>.
  void _notifyRedeemRequestDialogScreen() {
    final redeemRequestNotifier =
        ref.read(ownerRedeemRequestDialogRedeemRequestProvider.notifier);
    redeemRequestNotifier.set(null);
    redeemRequestNotifier.set(widget.redeemRequest);
  }
}
