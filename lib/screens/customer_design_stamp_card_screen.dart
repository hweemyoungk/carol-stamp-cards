import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/blueprint_notifier.dart';
import 'package:carol/screens/card_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  var _status = StampCardDesignStatus.userInput;
  final _formKey = GlobalKey<FormState>();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Card'),
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
                        decoration: const InputDecoration(
                          label: Text('Display Name'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.trim().length > 30) {
                            return 'Must be between 1 and 30 characters long';
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
                              label: const Text('Your Goal'),
                              suffixText: 'stamps',
                              suffixStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            ),
                            validator: (value) {
                              final blueprint = ref.read(
                                  customerDesignCardScreenBlueprintProvider);
                              if (blueprint == null) {
                                return 'Lost blueprint data... Go back and start over.';
                              }
                              if (value == null ||
                                  int.tryParse(value) == null ||
                                  int.parse(value) < 1 ||
                                  int.parse(value) > blueprint.numMaxStamps) {
                                return 'Must be integer between 1~${blueprint.numMaxStamps}';
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
        text: 'Lost card data... Go back and start over.',
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
        contextMessage: 'Failed to mofify card.',
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
      text: 'Card modified!',
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
