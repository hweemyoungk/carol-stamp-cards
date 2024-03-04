import 'package:carol/apis/owner_apis.dart';
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/stamp_grant.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/blueprint/blueprint_info.dart';
import 'package:carol/widgets/common/circular_progress_indicator_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnerGrantStampsScreen extends ConsumerStatefulWidget {
  final StampCard stampCard;
  final Blueprint blueprint;

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
  late AppLocalizations _localizations;
  late int _numGrant;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    final maxGrant =
        widget.blueprint.numMaxStamps - widget.stampCard.numCollectedStamps;
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizations.grantStampsAppBarTitle),
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
                            labelText: _localizations.grant,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                            suffixText: _localizations.stamps,
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
                              return _localizations
                                  .integerRangeViolationMessage(1, maxGrant);
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
                        _localizations.upToMaxStampsAllowed(maxGrant),
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
                          _localizations.back,
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
                            ? Text(_localizations.grantStamps)
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

    // POST StampGrant
    try {
      // await grantStamp(
      //   stampCardId: widget.stampCard.id,
      //   numStamps: _numGrant,
      // );
      final stampGrant = StampGrant(
        id: -1,
        isDeleted: false,
        displayName: 'Dummy Stamp Grant Name',
        numStamps: _numGrant,
        card: null,
        cardId: widget.stampCard.id,
      );
      await postStampGrant(stampGrant: stampGrant);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToGrantStamps,
        localizations: _localizations,
      );
      if (mounted) {
        setState(() {
          _status = GrantStatus.userInput;
        });
      }
      return;
    }

    Carol.showTextSnackBar(
      text: _localizations.grantStampsSuccess,
      level: SnackBarLevel.success,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
    return;
  }
}

enum GrantStatus {
  userInput,
  sending,
}
