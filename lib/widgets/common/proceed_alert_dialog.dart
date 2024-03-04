import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Has following behavior.
/// <ul>Pressing <code>Back</code> button will pop dialog and yield <code>false</code>.</ul>
/// <ul>Pressing <code>Proceed</code> button will pop dialog and yield <code>true</code>.</ul>
class ProceedAlertDialog extends StatelessWidget {
  const ProceedAlertDialog({
    super.key,
    // required this.ctx,
    required this.title,
    required this.content,
    this.proceedButtonString,
    this.proceedButtonStringColor,
    this.proceedButtonColor,
  });

  // final BuildContext ctx;
  final Widget? title;
  final Widget? content;
  final String? proceedButtonString;
  final Color? proceedButtonStringColor;
  final Color? proceedButtonColor;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: title,
      content: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (content != null) content!,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: DesignUtils.basicWidgetEdgeInsets(),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.background),
                      onPressed: () {
                        // Navigator.of(ctx).pop(false);
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        localizations.back,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                  ),
                  Padding(
                    padding: DesignUtils.basicWidgetEdgeInsets(),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: proceedButtonColor ??
                              Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        // Navigator.of(ctx).pop(true);
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        proceedButtonString ?? localizations.proceed,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: proceedButtonStringColor ??
                                Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
