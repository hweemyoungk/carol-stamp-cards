import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/user.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class IssueStampCardDialogScreen extends ConsumerStatefulWidget {
  const IssueStampCardDialogScreen({
    super.key,
    required this.blueprintProvider,
  });

  final StateNotifierProvider<EntityStateNotifier<StampCardBlueprint>,
      StampCardBlueprint> blueprintProvider;

  @override
  ConsumerState<IssueStampCardDialogScreen> createState() =>
      _IssueStampCardDialogScreenState();
}

class _IssueStampCardDialogScreenState
    extends ConsumerState<IssueStampCardDialogScreen> {
  bool? _isIssuable;
  Widget? _unissuableAlerts;
  final List<Widget> _alertRows = [];
  late Widget _issueButton;
  bool _issuing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final blueprint = ref.watch(widget.blueprintProvider);

    if (_isIssuable == null) {
      _checkIssuable(
        user: currentUser,
        blueprint: blueprint,
      );
    }

    _issueButton = _isIssuable == null
        ? ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
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
          )
        : !_isIssuable!
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
    _unissuableAlerts = _isIssuable == null || _isIssuable!
        ? null
        : Column(children: _alertRows);
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
                style: const TextStyle(fontSize: 24),
              ),
            ),
            if (_unissuableAlerts != null) _unissuableAlerts!,
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

  Future<void> _checkIssuable({
    required User user,
    required StampCardBlueprint blueprint,
  }) async {
    if (mounted) {
      setState(() {
        _alertRows.clear();
      });
    }

    // Check max issues
    Future<bool> numMaxIssuesTask = blueprint.numMaxIssues == 0
        ? Future.value(false)
        : _violatedNumMaxIssues(
            user: user,
            blueprint: blueprint,
          ).then((violated) {
            if (violated) {
              if (mounted) {
                setState(() {
                  _isIssuable = false;
                  _alertRows.add(
                    const AlertRow(text: 'Exceeded max number of issues'),
                  );
                });
              }
            }
            return violated;
          });

    // Assume another check
    Future<bool> veryLongTask = Utils.delaySeconds(5).then((value) {
      if (random.nextDouble() < 0.5) {
        return false;
      }
      if (mounted) {
        setState(() {
          _isIssuable = false;
          _alertRows.add(
            const AlertRow(text: 'Violated very long check task'),
          );
        });
      }
      return true;
    });

    final tasks = [
      numMaxIssuesTask,
      veryLongTask,
    ];
    final violations = await Future.wait(tasks);
    if (violations.every((violated) => !violated)) {
      if (mounted) {
        setState(() {
          _isIssuable = true;
        });
      }
    }
  }

  Future<bool> _violatedNumMaxIssues({
    required User user,
    required StampCardBlueprint blueprint,
  }) async {
    final numIssuedCards = await getNumIssuedCards(
      userId: user.id,
      blueprintId: blueprint.id,
    );
    return blueprint.numMaxIssues <= numIssuedCards;
  }

  Future<int> getNumIssuedCards({
    required String userId,
    required String blueprintId,
  }) async {
    // TODO replace with http
    await Utils.delaySeconds(2);
    return random.nextInt(3);
  }

  void _onPressIssue() {}

  void _onPressBack() {}
}

class AlertRow extends StatelessWidget {
  const AlertRow({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.errorContainer,
          ),
        ),
        Text(text),
      ],
    );
  }
}
