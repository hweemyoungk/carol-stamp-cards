import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/blueprint_notifier.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                        maxLength: 50,
                        decoration: const InputDecoration(
                          label: Text('Display Name'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.trim().length > 50) {
                            return 'Must be between 1 and 50 characters long';
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
      return;
    }

    final stampCardToPut = card.copyWith(
      displayName: _displayName,
      numGoalStamps: _numGoalStamps,
    );
    try {
      await customer_apis.putStampCard(
        id: stampCardToPut.id,
        stampCard: stampCardToPut,
      );
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to mofify card.',
      );
      return;
    }

    // Get StampCard
    final StampCard modifiedStampCard;
    try {
      modifiedStampCard =
          await customer_apis.getStampCard(id: stampCardToPut.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to get modified card information.',
      );
      return;
    }
    // TODO: customerPropagateCard(modifiedStampCard);

    Carol.showTextSnackBar(
      text: 'Card modified!',
      level: SnackBarLevel.success,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

enum StampCardDesignStatus {
  userInput,
  sending,
}
