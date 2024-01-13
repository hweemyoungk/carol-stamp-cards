import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/blueprint/blueprint_info.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerGrantStampsScreen extends ConsumerStatefulWidget {
  final StampCard stampCard;
  final StampCardBlueprint blueprint;

  const OwnerGrantStampsScreen({
    super.key,
    required this.stampCard,
    required this.blueprint,
  });

  @override
  ConsumerState<OwnerGrantStampsScreen> createState() =>
      _OwnerGrantStampsScreenState();
}

class _OwnerGrantStampsScreenState
    extends ConsumerState<OwnerGrantStampsScreen> {
  var _status = GrantStatus.userInput;
  final _formKey = GlobalKey<FormState>();
  late int _numGrant;

  @override
  Widget build(BuildContext context) {
    final maxGrant =
        widget.blueprint.numMaxStamps - widget.stampCard.numCollectedStamps;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grant Stamps'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: DesignUtils.basicWidgetEdgeInsets(),
                  padding: DesignUtils.basicWidgetEdgeInsets(),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: DesignUtils.basicWidgetEdgeInsets(),
                        child: Text(
                          widget.blueprint.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                        ),
                      ),
                      BlueprintInfo(
                        blueprint: widget.blueprint,
                        textColor: Theme.of(context).colorScheme.onBackground,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: DesignUtils.basicWidgetEdgeInsets(),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                          decoration: InputDecoration(
                            labelText: 'Grant',
                            labelStyle: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                            suffixText: 'stamps',
                            suffixStyle: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                          ),
                          validator: (value) {
                            if (value == null ||
                                int.tryParse(value) == null ||
                                int.parse(value) < 1 ||
                                int.parse(value) > maxGrant) {
                              return 'Must be in 1~$maxGrant';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          onSaved: (newValue) {
                            _numGrant = int.parse(newValue!);
                          },
                        ),
                      ),
                      Text(
                        'Up to $maxGrant stamps allowed',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        label: Text(
                          'Back',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size.fromWidth(200),
                            backgroundColor:
                                Theme.of(context).colorScheme.background),
                      ),
                      ElevatedButton.icon(
                        onPressed: _status == GrantStatus.userInput
                            ? _onPressGrant
                            : null,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor:
                              Theme.of(context).colorScheme.surface,
                        ),
                        icon: Icon(
                          Icons.forward,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: _status == GrantStatus.userInput
                            ? const Text('Grant stamps')
                            : CircularProgressIndicatorInButton(
                                color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPressGrant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _status = GrantStatus.sending;
    });

    // TODO: POST GrantHistory
    // await apis.owner.postGrantHistory(
    //   stampCardId: widget.stampCard.id,
    //   numGrant: _numGrant,
    // );
    final isSuccessful = await DesignUtils.delaySeconds(2)
        .then((value) => random.nextDouble() < 0.8);

    if (isSuccessful) {
      Carol.showTextSnackBar(text: 'Grant successful!');
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    Carol.showTextSnackBar(text: 'ERROR: Grant failed');
    return;
  }
}

enum GrantStatus {
  userInput,
  sending,
}
