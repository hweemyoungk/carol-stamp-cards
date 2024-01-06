import 'package:carol/data/dummy_data.dart';
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerDesignBlueprintScreen extends ConsumerStatefulWidget {
  const OwnerDesignBlueprintScreen({
    super.key,
    required this.designMode,
    required this.storeProvider,
    this.blueprint,
  });
  final BlueprintDesignMode designMode;
  final StateNotifierProvider<EntityStateNotifier<Store>, Store> storeProvider;
  final StampCardBlueprint? blueprint;

  @override
  ConsumerState<OwnerDesignBlueprintScreen> createState() =>
      _OwnerDesignStoreScreenState();
}

class _OwnerDesignStoreScreenState
    extends ConsumerState<OwnerDesignBlueprintScreen> {
  var _status = BlueprintDesignStatus.userInput;
  final _formKey = GlobalKey<FormState>();
  late String _displayName;
  late String _description;
  late String _stampGrantCondDescription;
  late int _numMaxStamps;
  late int _numMaxRedeems;
  late int _numMaxIssues;
  // late DateTime _lastModifiedDate;
  final List<RedeemRule> _redeemRules = [];
  DateTime? _expirationDate;
  // late String _storeId;
  // late IconData? _icon;
  // late String? _bgImageUrl;
  bool _isPublishing = true;

  @override
  void initState() {
    super.initState();
    if (widget.blueprint != null) {
      final blueprint = widget.blueprint!;
      // Set _isPublishing
      _isPublishing = blueprint.isPublishing;
      // Set _expirationDate
      _expirationDate = blueprint.expirationDate;
      // Set _redeemRules
      // RedeemRules must be fetched in _BlueprintDialogScreenState._onPressModify
      _redeemRules.addAll(blueprint.redeemRules!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designMode == BlueprintDesignMode.create
            ? 'New Blueprint'
            : 'Modify Blueprint'),
        actions: [
          _status == BlueprintDesignStatus.userInput
              ? IconButton(
                  onPressed: _saveBlueprint,
                  icon: const Icon(Icons.check),
                )
              : Padding(
                  padding: Utils.basicWidgetEdgeInsets(),
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
              // final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: Utils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue: widget.blueprint?.displayName,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 50,
                        decoration: const InputDecoration(
                          label: Text('Display Name'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().length <= 1 ||
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
                      padding: Utils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue: widget.blueprint?.description,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          label: Text('Description'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().length <= 1 ||
                              value.trim().length > 1000) {
                            return 'Must be between 1 and 1000 characters long';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _description = newValue!;
                        },
                      ),
                    ),
                    Padding(
                      padding: Utils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue:
                            widget.blueprint?.stampGrantCondDescription,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          label: Text('Stamp Grant Conditions'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().length <= 1 ||
                              value.trim().length > 1000) {
                            return 'Must be between 1 and 1000 characters long';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _stampGrantCondDescription = newValue!;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // late int _numMaxStamps;
                        Padding(
                          padding: Utils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue:
                                  widget.blueprint?.numMaxStamps.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                              // double _lng;
                              decoration: const InputDecoration(
                                label: Text('Max Stamps'),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    int.tryParse(value) == null ||
                                    int.parse(value) < 1 ||
                                    100 < int.parse(value)) {
                                  return 'Must be in 1~100';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onSaved: (newValue) {
                                _numMaxStamps = int.parse(newValue!);
                              },
                            ),
                          ),
                        ),
                        // late int _numMaxRedeems;
                        Padding(
                          padding: Utils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue:
                                  widget.blueprint?.numMaxStamps.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                              // double _lng;
                              decoration: const InputDecoration(
                                label: Text('Max Redeems'),
                              ),
                              validator: (value) {
                                // 0 is infinite
                                if (value == null ||
                                    int.tryParse(value) == null ||
                                    int.parse(value) < 0 ||
                                    100 < int.parse(value)) {
                                  return 'Must be in 0~100';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onSaved: (newValue) {
                                _numMaxRedeems = int.parse(newValue!);
                              },
                            ),
                          ),
                        ),
                        // late int _numMaxIssues;
                        Padding(
                          padding: Utils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue:
                                  widget.blueprint?.numMaxStamps.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                              // double _lng;
                              decoration: const InputDecoration(
                                label: Text('Max Issues per customer'),
                              ),
                              validator: (value) {
                                // 0 is infinite
                                if (value == null ||
                                    int.tryParse(value) == null ||
                                    int.parse(value) < 1 ||
                                    100 < int.parse(value)) {
                                  return 'Must be in 1~100';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onSaved: (newValue) {
                                _numMaxIssues = int.parse(newValue!);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // DateTime? _expirationDate;
                    Row(
                      children: [
                        Padding(
                          padding: Utils.basicWidgetEdgeInsets(),
                          child: Text(
                            'Redeem Rules',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                          ),
                        ),
                        IconButton(
                          onPressed: _onPressAddRedeemRule,
                          icon: Icon(
                            Icons.add_box,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: Utils.basicWidgetEdgeInsets(),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: 1,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _redeemRules.length,
                              itemBuilder: (ctx, index) {
                                final redeemRule = _redeemRules[index];
                                return ListTile(
                                  dense: true,
                                  visualDensity:
                                      const VisualDensity(vertical: -3),
                                  title: Text(redeemRule.displayName),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: Utils.basicWidgetEdgeInsets(),
                          child: Text(
                            'Expiration Date',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                          ),
                        ),
                        Padding(
                          padding: Utils.basicWidgetEdgeInsets(),
                          child: Text(
                            _expirationDate == null
                                ? 'No date selected'
                                : formatter.format(_expirationDate!),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                          ),
                        ),
                        Padding(
                          padding: Utils.basicWidgetEdgeInsets(),
                          child: IconButton(
                            onPressed:
                                widget.designMode == BlueprintDesignMode.modify
                                    ? null
                                    : _onPressSelectExpDate,
                            icon: Icon(Icons.calendar_month,
                                color: widget.designMode ==
                                        BlueprintDesignMode.modify
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.3)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: Utils.basicWidgetEdgeInsets(),
                          child: Text(
                            'Publish Now',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Switch(
                          value: _isPublishing,
                          onChanged: (value) {
                            setState(() {
                              _isPublishing = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }

  void _saveBlueprint() async {
    // final ownerStoresNotifier = ref.read(ownerStoresProvider.notifier);
    final store = ref.read(widget.storeProvider);
    final storeNotifier = ref.read(widget.storeProvider.notifier);

    if (!_validateInput()) {
      return;
    }

    setState(() {
      _status = BlueprintDesignStatus.sending;
    });
    _formKey.currentState!.save();

    if (widget.designMode == BlueprintDesignMode.create) {
      // TODO POST Store
      await Utils.delaySeconds(2);
      final location = uuid.v4();
      final newBlueprint = StampCardBlueprint(
        id: location,
        displayName: _displayName,
        description: _description,
        stampGrantCondDescription: _stampGrantCondDescription,
        numMaxStamps: _numMaxStamps,
        lastModifiedDate: DateTime.now(),
        expirationDate: _expirationDate!,
        numMaxRedeems: _numMaxRedeems,
        numMaxIssues: _numMaxIssues,
        storeId: store.id,
        icon: null,
        bgImageUrl: null,
        isPublishing: _isPublishing,
        redeemRules: null, // TODO Assign from input
      );
      blueprintProviders.tryAddProvider(entity: newBlueprint);
      if (store.blueprints == null) {
        storeNotifier.set(entity: store.copyWith(blueprints: [newBlueprint]));
      } else {
        storeNotifier.set(
            entity: store
                .copyWith(blueprints: [newBlueprint, ...store.blueprints!]));
      }
      ScaffoldMessenger.of(Carol.materialKey.currentContext!)
          .showSnackBar(const SnackBar(
        content: Text('New Blueprint Created!'),
        duration: Duration(seconds: 3),
      ));
    } else {
      // TODO PUT Store
      final blueprintProvider =
          blueprintProviders.tryGetProviderById(id: widget.blueprint!.id);
      final blueprint = ref.read(blueprintProvider!);
      final blueprintNotifier = ref.read(blueprintProvider!.notifier);
      await Utils.delaySeconds(2);
      // TODO: Create, modify, or delete redeemRules

      final modifiedBlueprint = blueprint.copyWith(
        displayName: _displayName,
        description: _description,
        stampGrantCondDescription: _stampGrantCondDescription,
        numMaxStamps: _numMaxStamps,
        lastModifiedDate: DateTime.now(),
        expirationDate: _expirationDate!,
        numMaxRedeems: _numMaxRedeems,
        numMaxIssues: _numMaxIssues,
        isPublishing: _isPublishing,
        redeemRules: _redeemRules,
      );
      if (blueprintProviders.tryGetProviderById(id: widget.blueprint!.id) !=
          null) {
        blueprintNotifier.set(entity: modifiedBlueprint);
        ScaffoldMessenger.of(Carol.materialKey.currentContext!)
            .showSnackBar(const SnackBar(
          content: Text('Blueprint Modified!'),
          duration: Duration(seconds: 3),
        ));
      } else {
        // Very unlikely but what if blueprint was deleted while modifying?
        ScaffoldMessenger.of(Carol.materialKey.currentContext!)
            .showSnackBar(const SnackBar(
          content: Text('Error: Invalid Blueprint. Please refresh.'),
          duration: Duration(seconds: 3),
        ));
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onPressSelectExpDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(days: 1));
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    // Show date picker
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    setState(() {
      _expirationDate = selectedDate;
    });
  }

  bool _validateInput() {
    return _formKey.currentState!.validate() && _expirationDate != null;
  }

  void _onPressAddRedeemRule() {
    // TODO Implement
  }

  Future<List<RedeemRule>> loadRedeemRules(
      {required StampCardBlueprint blueprint}) async {
    final redeemRules =
        await Utils.delaySeconds(1).then((value) => genDummySortedRedeemRules(
              blueprint: widget.blueprint!,
              numRules: 3,
            ));
    return redeemRules;
  }
}

enum BlueprintDesignStatus {
  userInput,
  sending,
}

enum BlueprintDesignMode {
  create,
  modify,
}
