import 'dart:async';
import 'package:carol/apis/utils.dart';
import 'package:carol/models/app_notice.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppNoticeDialogScreen extends StatefulWidget {
  const AppNoticeDialogScreen({
    super.key,
    required this.notice,
  });

  final AppNotice notice;

  @override
  State<AppNoticeDialogScreen> createState() => _AppNoticeDialogScreenState();
}

class _AppNoticeDialogScreenState extends State<AppNoticeDialogScreen> {
  late AppLocalizations _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.notice.displayName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: DesignUtils.basicWidgetEdgeInsets(),
              child: Text(widget.notice.description),
            ),
            if (widget.notice.url != null)
              ElevatedButton(
                onPressed: _onPressDetail,
                child: Text(_localizations.readDetail),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_localizations.close),
            ),
            if (widget.notice.canSuppress)
              ElevatedButton(
                onPressed: _onPressSuppress,
                child: Text(_localizations.doNotShowAgain),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPressDetail() async {
    if (widget.notice.url == null) {
      return;
    }
    await launchInBrowserView(widget.notice.url!);
  }

  void _onPressSuppress() {
    Navigator.of(context).pop(true);
  }
}
