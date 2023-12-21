import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class IssueStampCardDialogScreen extends ConsumerStatefulWidget {
  const IssueStampCardDialogScreen({
    super.key,
    required this.blueprintProvider,
  });

  final StateNotifierProvider<StampCardBlueprintNotifier, StampCardBlueprint>
      blueprintProvider;

  @override
  ConsumerState<IssueStampCardDialogScreen> createState() =>
      _IssueStampCardDialogScreenState();
}

class _IssueStampCardDialogScreenState
    extends ConsumerState<IssueStampCardDialogScreen> {
  bool _issuing = false;
  late bool _isIssuable;
  late Widget _issueButton;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final blueprint = ref.watch(widget.blueprintProvider);

    _isIssuable = _checkIssuable(blueprint: blueprint);
    _issueButton = !_isIssuable
        ? ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
                disabledBackgroundColor:
                    Theme.of(context).colorScheme.errorContainer),
            child: Text(
              'Cannot issue this card!',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          )
        : ElevatedButton(
            onPressed: _onPressIssue,
            child: const Text('Get this card'),
          );
    Widget? alerts = _isIssuable
        ? null
        : Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.errorContainer,
                    ),
                  ),
                  Text('Here comes why not issuable...'),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.errorContainer,
                    ),
                  ),
                  Text('Here comes why not issuable...'),
                ],
              ),
            ],
          );
    Widget image = blueprint.bgImageUrl == null
        ? Image.memory(
            kTransparentImage,
            fit: BoxFit.contain,
          )
        : Image.asset(
            blueprint.bgImageUrl!,
            fit: BoxFit.contain,
          );
    return AlertDialog(
      title: Text(blueprint.displayName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            image,
            Padding(
              padding: Utils.basicWidgetEdgeInsets(),
              child: Text(
                blueprint.description,
              ),
            ),
            Padding(
              padding: Utils.basicWidgetEdgeInsets(),
              child: Text(
                'Stamp Grant Conditions',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
            Padding(
              padding: Utils.basicWidgetEdgeInsets(),
              child: Text(blueprint.stampGrantCondDescription),
            ),
            Padding(
              padding: Utils.basicWidgetEdgeInsets(),
              child: TextFormField(
                enabled: _isIssuable,
                decoration: InputDecoration(
                  labelText: 'Card Name',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                initialValue: blueprint.displayName,
                style: TextStyle(fontSize: 24),
              ),
            ),
            if (alerts != null) alerts,
            TextButton(
              onPressed: _onPressBack,
              child: const Text(
                'Back',
                textAlign: TextAlign.end,
              ),
            ),
            _issueButton,
          ],
        ),
      ),
    );
  }

  bool _checkIssuable({
    // required User user,
    required StampCardBlueprint blueprint,
  }) {
    return random.nextDouble() < 0.5;
  }

  void _onPressIssue() {}

  void _onPressBack() {}
}
