import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/blueprint_notifier.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/common/required_field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool isSavingCard = false;
final customerDesignCardScreenBlueprintProvider =
    StateNotifierProvider<BlueprintNotifier, Blueprint?>(
        (ref) => BlueprintNotifier(null));

class CustomerDesignStampCardScreen extends ConsumerStatefulWidget {
  const CustomerDesignStampCardScreen({
    super.key,
    this.card,
  });
  final StampCard? card;

  @override
  ConsumerState<CustomerDesignStampCardScreen> createState() =>
      _CustomerDesignStampCardScreenState();
}

class _CustomerDesignStampCardScreenState
    extends ConsumerState<CustomerDesignStampCardScreen> {
  final _formKey = GlobalKey<FormState>();
  var _status = StampCardDesignStatus.userInput;
  late AppLocalizations _localizations;
  String? _displayName;
  int? _numGoalStamps;

  @override
  void initState() {
    super.initState();
    _displayName = widget.card?.displayName;
    _numGoalStamps = widget.card?.numGoalStamps;
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizations.modifyCardAppBarTitle),
        actions: [
          _status == StampCardDesignStatus.userInput
              ? IconButton(
                  onPressed: _modifyCard,
                  icon: const Icon(Icons.check),
                )
              : Padding(
                  padding: DesignUtils.basicWidgetEdgeInsets(),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(),
                  ),
                ),
        ],
      ),
      body: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: DesignUtils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue: widget.card?.displayName,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 30,
                        decoration: InputDecoration(
                          label: RequiredFieldLabel(
                            Text(_localizations.displayName),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.trim().length > 30) {
                            return _localizations.textLengthViolationMessage(
                                1, 30);
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _displayName = newValue!;
                        },
                      ),
                    ),
                    Padding(
                      padding: DesignUtils.basicWidgetEdgeInsets(),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: widget.card?.numGoalStamps.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                            decoration: InputDecoration(
                              label: RequiredFieldLabel(
                                Text(_localizations.yourGoal),
                              ),
                              suffixText: _localizations.stamps,
                              suffixStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            ),
                            validator: (value) {
                              final blueprint = ref.read(
                                  customerDesignCardScreenBlueprintProvider);
                              if (blueprint == null) {
                                return _localizations.lostBlueprintData;
                              }
                              if (value == null ||
                                  int.tryParse(value) == null ||
                                  int.parse(value) < 1 ||
                                  int.parse(value) > blueprint.numMaxStamps) {
                                return _localizations
                                    .integerRangeViolationMessage(
                                        1, blueprint.numMaxStamps);
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            onSaved: (newValue) {
                              _numGoalStamps = int.parse(newValue!);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }

  Future<void> _modifyCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    isSavingCard = true;
    final cardsNotifier = ref.read(customerCardsListCardsProvider.notifier);
    final cardNotifier = ref.read(customerCardScreenCardProvider.notifier);

    _formKey.currentState!.save();

    setState(() {
      _status = StampCardDesignStatus.sending;
    });

    // PUT StampCard
    final card = widget.card;
    if (card == null) {
      Carol.showTextSnackBar(
        text: _localizations.lostCardData,
        level: SnackBarLevel.error,
      );
      if (mounted) {
        setState(() {
          _status = StampCardDesignStatus.userInput;
        });
      }
      isSavingCard = false;
      return;
    }

    final cardToPut = card.copyWith(
      displayName: _displayName,
      numGoalStamps: _numGoalStamps,
    );
    try {
      await customer_apis.putStampCard(
        id: cardToPut.id,
        stampCard: cardToPut,
      );
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: _localizations.failedToModifyCard,
        localizations: _localizations,
      );
      if (mounted) {
        setState(() {
          _status = StampCardDesignStatus.userInput;
        });
      }
      isSavingCard = false;
      return;
    }

    // Get StampCard
    // Do not getStampCard: cardNotifier needs card.blueprint.redeemRules
    // final StampCard modifiedCard;
    // try {
    //   modifiedCard = await customer_apis.getStampCard(id: cardToPut.id);
    // } on Exception catch (e) {
    //   Carol.showExceptionSnackBar(
    //     e,
    //     contextMessage: 'Failed to get modified card information.',
    //   );
    // isSavingCard = false;
    //   return;
    // }
    final modifiedCard = cardToPut;

    // Propagate
    // customerCardsListCardsProvider
    cardsNotifier.replaceOrPrepend(modifiedCard);
    // customerStoresListStoresProvider: Not relavant
    // customerCardScreenCardProvider
    cardNotifier.set(modifiedCard);
    // customerDesignCardScreenBlueprintProvider: Not relavent

    Carol.showTextSnackBar(
      text: _localizations.modifyCardSuccess,
      level: SnackBarLevel.success,
    );
    isSavingCard = false;
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

enum StampCardDesignStatus {
  userInput,
  sending,
}
