import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/screens/redeem_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RedeemRuleListItem extends ConsumerStatefulWidget {
  final StampCard? card;
  final RedeemRule redeemRule;
  final TextStyle style;
  final Color color;

  const RedeemRuleListItem({
    super.key,
    required this.card,
    required this.redeemRule,
    required this.style,
    required this.color,
  });

  @override
  ConsumerState<RedeemRuleListItem> createState() => _RedeemRuleListItemState();
}

class _RedeemRuleListItemState extends ConsumerState<RedeemRuleListItem> {
  late AppLocalizations _localizations;
  String? _redeemRequestId;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    final card = widget.card;
    final redeemRule = widget.redeemRule;
    final redeemable =
        card == null ? null : redeemRule.consumes <= card.numCollectedStamps;
    final appliedColor = redeemable == null || redeemable
        ? widget.color
        : widget.color.withOpacity(.2);
    return ListTile(
      // Compact form in case of BlueprintInfo
      visualDensity: card == null ? const VisualDensity(vertical: -4.0) : null,
      onTap: card == null
          ? null
          : () async {
              await showDialog(
                context: context,
                builder: (ctx) {
                  return RedeemDialogScreen(
                    card: card,
                    redeemRule: redeemRule,
                    setRedeemRequestIdToParent:
                        _setRedeemRequestIdToRedeemRuleListItem,
                  );
                },
              );
              _tryCleanUpRedeemRequest();
            },
      key: ValueKey(redeemRule.id),
      leading: redeemRule.consumesWidget(
        widget.style,
        appliedColor,
      ),
      title: Text(
        redeemRule.displayName,
        style: widget.style.copyWith(color: appliedColor),
      ),
    );
  }

  void _setRedeemRequestIdToRedeemRuleListItem(String? redeemRequestId) {
    _redeemRequestId = redeemRequestId;
  }

  void _tryCleanUpRedeemRequest() {
    if (_redeemRequestId == null) return;
    // Try deleting redeem request
    _deleteRedeemRequest(_redeemRequestId!);
    _redeemRequestId = null;
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
