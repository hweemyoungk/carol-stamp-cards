import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/stamp_card_blueprint_provider.dart';
import 'package:carol/screens/owner_design_redeem_rule_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/icon_button_in_progress.dart';
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
  late TextEditingController _maxStampController;
  late int _numMaxStamps;
  late int _numMaxRedeems;
  late int _numMaxIssuesPerCustomer;
  late int _numMaxIssues;
  // late DateTime _lastModifiedDate;
  final List<RedeemRule> _redeemRules = [];
  List<bool>? _illegalRedeemRules;
  DateTime? _expirationDate;
  // late String _storeId;
  // late IconData? _icon;
  // late String? _bgImageUrl;
  bool _isPublishing = true;

  @override
  void initState() {
    super.initState();
    _maxStampController =
        TextEditingController(text: widget.blueprint?.numMaxStamps.toString());
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
  void dispose() {
    _maxStampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onBackgroundTernary = widget.designMode == BlueprintDesignMode.modify
        ? Theme.of(context).colorScheme.onBackground.withOpacity(0.4)
        : Theme.of(context).colorScheme.onBackground;
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
              : const IconButtonInProgress(),
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
                      padding: DesignUtils.basicWidgetEdgeInsets(),
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
                      padding: DesignUtils.basicWidgetEdgeInsets(),
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
                      padding: DesignUtils.basicWidgetEdgeInsets(),
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
                              value.trim().isEmpty ||
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
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 100,
                            child: TextFormField(
                              // initialValue: widget.blueprint?.numMaxStamps.toString(),
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
                                  return 'Must be integer';
                                }
                                final input = int.parse(value);
                                if (widget.blueprint != null &&
                                    input < widget.blueprint!.numMaxStamps) {
                                  return 'Cannot reduce max stamps';
                                }
                                if (input < 1 || 100 < input) {
                                  return 'Must be in 1~100';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              controller: _maxStampController,
                              onSaved: (newValue) {
                                _numMaxStamps = int.parse(newValue!);
                              },
                            ),
                          ),
                        ),
                        // late int _numMaxRedeems;
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
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
                        // late int _numMaxIssuesPerCustomer;
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: widget
                                  .blueprint?.numMaxIssuesPerCustomer
                                  .toString(),
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
                                _numMaxIssuesPerCustomer = int.parse(newValue!);
                              },
                            ),
                          ),
                        ),
                        // late int _numMaxIssues;
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue:
                                  widget.blueprint?.numMaxIssues.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                              decoration: const InputDecoration(
                                label: Text('Max Total Issues(0 for infinite)'),
                              ),
                              validator: (value) {
                                // 0 is infinite
                                if (value == null ||
                                    int.tryParse(value) == null ||
                                    int.parse(value) < 0) {
                                  return 'Must be 0+ integer';
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
                    Row(
                      children: [
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
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
                            margin: DesignUtils.basicWidgetEdgeInsets(),
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
                                final isIllegal = _illegalRedeemRules?[index];
                                return ListTile(
                                  dense: true,
                                  visualDensity:
                                      const VisualDensity(vertical: -3),
                                  title: Text(
                                    redeemRule.displayName,
                                    style: isIllegal != null && isIllegal
                                        ? TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          )
                                        : redeemRule.id != -1
                                            ? null
                                            : TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                  ),
                                  trailing: isIllegal != null && isIllegal
                                      ? Icon(
                                          Icons.error,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        )
                                      : null,
                                  onTap: () async {
                                    final outputRedeemRule =
                                        await Navigator.of(context)
                                            .push<RedeemRule>(MaterialPageRoute(
                                      builder: (context) =>
                                          OwnerDesignRedeemRuleScreen(
                                        designMode: RedeemRuleDesignMode.modify,
                                        blueprint: widget.blueprint,
                                        redeemRule: redeemRule,
                                      ),
                                    ));
                                    if (outputRedeemRule == null) {
                                      return;
                                    }
                                    if (outputRedeemRule.blueprintId == -1) {
                                      // Deleted
                                      if (mounted) {
                                        setState(() {
                                          _illegalRedeemRules = null;
                                          _redeemRules.removeAt(index);
                                        });
                                      }
                                      return;
                                    }
                                    if (mounted) {
                                      setState(() {
                                        _illegalRedeemRules = null;
                                        _redeemRules[index] = outputRedeemRule;
                                      });
                                    }
                                  },
                                );
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
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: Text(
                            'Expiration Date',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: onBackgroundTernary),
                          ),
                        ),
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: _expirationDate == null
                              ? Text(
                                  'No date selected',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                )
                              : Text(
                                  formatter.format(_expirationDate!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: onBackgroundTernary),
                                ),
                        ),
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: IconButton(
                            onPressed:
                                widget.designMode == BlueprintDesignMode.modify
                                    ? null
                                    : _onPressSelectExpDate,
                            icon: Icon(Icons.calendar_month,
                                color: onBackgroundTernary),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
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

  Future<void> _saveBlueprint() async {
    // final ownerStoresNotifier = ref.read(ownerStoresProvider.notifier);
    final store = ref.read(widget.storeProvider);
    final storeNotifier = ref.read(widget.storeProvider.notifier);

    if (!_validateInput()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _status = BlueprintDesignStatus.sending;
    });

    if (widget.designMode == BlueprintDesignMode.create) {
      // // POST blueprint and get location
      // await DesignUtils.delaySeconds(1);
      // final location = uuid.v4();
      // final redeemRuleTasks = _redeemRules.map((redeemRule) async {
      //   // POST every RedeemRule and get location
      //   await DesignUtils.delaySeconds(1);
      //   final location = uuid.v4();
      //   final postedRedeemRule = redeemRule.copyWith(id: location);
      //   redeemRuleProviders.tryAddProvider(entity: postedRedeemRule);
      //   return postedRedeemRule;
      // });
      // final processedRedeemRules = await Future.wait(redeemRuleTasks);
      final blueprintToPost = StampCardBlueprint(
        id: -1,
        displayName: _displayName,
        description: _description,
        stampGrantCondDescription: _stampGrantCondDescription,
        numMaxStamps: _numMaxStamps,
        lastModifiedDate: DateTime.now(),
        expirationDate: _expirationDate!,
        numMaxRedeems: _numMaxRedeems,
        numMaxIssuesPerCustomer: _numMaxIssuesPerCustomer,
        numMaxIssues: _numMaxIssues,
        storeId: store.id,
        bgImageUrl: null,
        isPublishing: _isPublishing,
        redeemRules: _redeemRules,
      );
      final newBlueprintId =
          await owner_apis.postBlueprint(blueprint: blueprintToPost);

      // Get blueprint(with redeemRules)
      // final newBlueprint = StampCardBlueprint(
      //   id: location,
      //   displayName: _displayName,
      //   description: _description,
      //   stampGrantCondDescription: _stampGrantCondDescription,
      //   numMaxStamps: _numMaxStamps,
      //   lastModifiedDate: DateTime.now(),
      //   expirationDate: _expirationDate!,
      //   numMaxRedeems: _numMaxRedeems,
      //   numMaxIssues: _numMaxIssues,
      //   storeId: store.id,
      //   icon: null,
      //   bgImageUrl: null,
      //   isPublishing: _isPublishing,
      //   redeemRules: processedRedeemRules,
      // );
      final newBlueprint = await owner_apis.getBlueprint(id: newBlueprintId);
      blueprintProviders.tryAddProvider(entity: newBlueprint);
      if (store.blueprints == null) {
        // Should not happen: Blueprints must be fetched already.
        throw Exception('Blueprints must be fetched already for store');
      } else {
        storeNotifier.set(
            entity: store
                .copyWith(blueprints: [newBlueprint, ...store.blueprints!]));
      }

      Carol.showTextSnackBar(
        text: 'Blueprint created!',
        level: SnackBarLevel.success,
      );
    } else {
      // BlueprintDesignMode.modify

      final blueprintNotifier = ref.read(
        blueprintProviders
            .tryGetProviderById(id: widget.blueprint!.id)!
            .notifier,
      );

      // PUT blueprint
      // final putBlueprintTask = DesignUtils.delaySeconds(2);
      // final redeemRuleTasks = _redeemRules.map((redeemRule) async {
      //   if (redeemRule.id == '') {
      //     // POST redeemRule and get location
      //     await DesignUtils.delaySeconds(1);
      //     final postedRedeemRule = redeemRule.copyWith(id: uuid.v4());
      //     redeemRuleProviders.tryAddProvider(entity: postedRedeemRule);
      //     return postedRedeemRule;
      //   } else {
      //     final redeemRuleProvider =
      //         redeemRuleProviders.tryGetProviderById(id: redeemRule.id)!;
      //     final redeemRuleNotifier = ref.read(redeemRuleProvider.notifier);
      //     final putRedeemRule = await putBlueprintTask.then(
      //       (value) {
      //         // PUT redeemRule
      //         DesignUtils.delaySeconds(2);
      //         return redeemRule.copyWith();
      //       },
      //     );
      //     if (redeemRuleProviders.tryGetProviderById(id: putRedeemRule.id) ==
      //         null) {
      //       // RedeemRule can't be deleted. Should not happen.
      //       throw Exception('Yeah we are fxcked...');
      //     }
      //     redeemRuleNotifier.set(entity: putRedeemRule);
      //     return putRedeemRule;
      //   }
      // });
      // final processedRedeemRules = await Future.wait(redeemRuleTasks);

      final blueprintToPut = StampCardBlueprint(
        id: widget.blueprint!.id,
        displayName: _displayName,
        description: _description,
        stampGrantCondDescription: _stampGrantCondDescription,
        numMaxStamps: _numMaxStamps,
        lastModifiedDate: DateTime.now(),
        expirationDate: _expirationDate!,
        numMaxRedeems: _numMaxRedeems,
        numMaxIssuesPerCustomer: _numMaxIssuesPerCustomer,
        numMaxIssues: _numMaxIssues,
        storeId: store.id,
        bgImageUrl: null,
        isPublishing: _isPublishing,
        redeemRules: _redeemRules,
      );
      await owner_apis.putBlueprint(
        id: widget.blueprint!.id,
        blueprint: blueprintToPut,
      );

      // Get blueprint
      // final modifiedBlueprint = blueprint.copyWith(
      //   displayName: _displayName,
      //   description: _description,
      //   stampGrantCondDescription: _stampGrantCondDescription,
      //   numMaxStamps: _numMaxStamps,
      //   lastModifiedDate: DateTime.now(),
      //   expirationDate: _expirationDate!,
      //   numMaxRedeems: _numMaxRedeems,
      //   numMaxIssues: _numMaxIssues,
      //   isPublishing: _isPublishing,
      //   redeemRules: processedRedeemRules,
      // );

      final modifiedBlueprint =
          await owner_apis.getBlueprint(id: widget.blueprint!.id);
      if (blueprintProviders.tryGetProviderById(id: widget.blueprint!.id) ==
          null) {
        // Very unlikely but what if blueprint was deleted while modifying?
        // Blueprint exists anyway, as server fetched modifiedBlueprint.
        Carol.showTextSnackBar(
          text: 'Error: Blueprint once deleted.',
          level: SnackBarLevel.warn,
        );
        blueprintProviders.tryAddProvider(entity: modifiedBlueprint);
      } else {
        blueprintNotifier.set(entity: modifiedBlueprint);
        Carol.showTextSnackBar(
          text: 'Blueprint Modified!',
          level: SnackBarLevel.success,
        );
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
    return;
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
    // Form validate
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    // expiration date
    if (_expirationDate == null || _expirationDate!.isBefore(DateTime.now())) {
      return false;
    }
    // every redeem rule's 'consumes' must be less or equal to blueprint's 'max stamps'
    setState(() {
      _illegalRedeemRules = _redeemRules
          .map((redeemRule) =>
              int.parse(_maxStampController.text) < redeemRule.consumes)
          .toList();
    });
    if (_illegalRedeemRules!.any((isIllegal) => isIllegal)) {
      return false;
    }

    return true;
  }

  Future<void> _onPressAddRedeemRule() async {
    final newRedeemRule =
        await Navigator.of(context).push<RedeemRule>(MaterialPageRoute(
      builder: (context) => OwnerDesignRedeemRuleScreen(
        designMode: RedeemRuleDesignMode.create,
        blueprint: widget.blueprint,
      ),
    ));
    if (newRedeemRule == null) {
      return;
    }
    if (mounted) {
      setState(() {
        _redeemRules.add(newRedeemRule);
      });
    }
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
