import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerDesignStampCardScreen extends ConsumerStatefulWidget {
  const CustomerDesignStampCardScreen({
    super.key,
    required this.stampCard,
    required this.blueprintProvider,
  });
  final StateNotifierProvider<EntityStateNotifier<StampCardBlueprint>,
      StampCardBlueprint> blueprintProvider;
  final StampCard stampCard;

  @override
  ConsumerState<CustomerDesignStampCardScreen> createState() =>
      _CustomerDesignStampCardScreenState();
}

class _CustomerDesignStampCardScreenState
    extends ConsumerState<CustomerDesignStampCardScreen> {
  var _status = StampCardDesignStatus.userInput;
  final _formKey = GlobalKey<FormState>();
  late String _displayName;
  late int _numGoalStamps;

  @override
  void initState() {
    super.initState();
    _displayName = widget.stampCard.displayName;
    _numGoalStamps = widget.stampCard.numGoalStamps;
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
                        initialValue: widget.stampCard.displayName,
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
                            initialValue:
                                widget.stampCard.numGoalStamps.toString(),
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
                              final blueprint =
                                  ref.read(widget.blueprintProvider);
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

    final stampCardProvider =
        stampCardProviders.tryGetProviderById(id: widget.stampCard.id)!;
    final stampCardNotifier = ref.read(stampCardProvider.notifier);

    // TODO: PUT StampCard
    await DesignUtils.delaySeconds(1);

    final modifiedStampCard = widget.stampCard.copyWith(
      displayName: _displayName,
      numGoalStamps: _numGoalStamps,
    );
    stampCardNotifier.set(entity: modifiedStampCard);
    Carol.showTextSnackBar(text: 'Card modified!');

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

enum StampCardDesignStatus {
  userInput,
  sending,
}
