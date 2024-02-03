import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/screens/owner_design_redeem_rule_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/icon_button_in_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerDesignBlueprintScreen extends ConsumerStatefulWidget {
  final BlueprintDesignMode designMode;
  final Blueprint? blueprint;

  const OwnerDesignBlueprintScreen({
    super.key,
    required this.designMode,
    this.blueprint,
  });

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
                        decoration: InputDecoration(
                          label: Text(
                            'Display Name',
                            style: TextStyle(
                              color: onBackgroundTernary,
                            ),
                          ),
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
                        decoration: InputDecoration(
                          label: Text(
                            'Description',
                            style: TextStyle(
                              color: onBackgroundTernary,
                            ),
                          ),
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
                        decoration: InputDecoration(
                          label: Text(
                            'Stamp Grant Conditions',
                            style: TextStyle(
                              color: onBackgroundTernary,
                            ),
                          ),
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
                              decoration: InputDecoration(
                                label: Text(
                                  'Max Stamps',
                                  style: TextStyle(
                                    color: onBackgroundTernary,
                                  ),
                                ),
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
                              decoration: InputDecoration(
                                label: Text(
                                  'Max Redeems',
                                  style: TextStyle(
                                    color: onBackgroundTernary,
                                  ),
                                ),
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              decoration: InputDecoration(
                                label: Text(
                                  'Max Issues per customer',
                                  style: TextStyle(
                                    color: onBackgroundTernary,
                                  ),
                                ),
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
                              decoration: InputDecoration(
                                label: Text(
                                  'Max Total Issues\n(0 for infinite)',
                                  style: TextStyle(
                                    color: onBackgroundTernary,
                                  ),
                                ),
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
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${timeFormatter.format(_expirationDate!)} ${dateFormatter.format(_expirationDate!)} ${_expirationDate!.timeZoneName} (UTC+${_expirationDate!.timeZoneOffset.inHours})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: onBackgroundTernary),
                                    ),
                                    Text(
                                      '(${formatRemaining(_expirationDate!.difference(DateTime.now()))})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: onBackgroundTernary),
                                    ),
                                  ],
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
    if (!_validateInput()) {
      return;
    }
    _formKey.currentState!.save();

    final store = ref.read(ownerStoreScreenStoreProvider);
    if (store == null) {
      Carol.showTextSnackBar(
        text: 'Missing store data... Please start over.',
        level: SnackBarLevel.error,
      );
      return;
    }

    setState(() {
      _status = BlueprintDesignStatus.sending;
    });

    if (widget.designMode == BlueprintDesignMode.create) {
      // POST blueprint and get location
      final blueprintToPost = Blueprint(
        id: -1,
        isDeleted: false,
        displayName: _displayName,
        description: _description,
        stampGrantCondDescription: _stampGrantCondDescription,
        numMaxStamps: _numMaxStamps,
        lastModifiedDate: DateTime.now(),
        expirationDate: _expirationDate!,
        numMaxRedeems: _numMaxRedeems,
        numMaxIssuesPerCustomer: _numMaxIssuesPerCustomer,
        numMaxIssues: _numMaxIssues,
        bgImageUrl: null,
        isPublishing: _isPublishing,
        store: null,
        storeId: store.id,
        redeemRules: _redeemRules.toSet(),
      );
      final int newBlueprintId;
      try {
        newBlueprintId =
            await owner_apis.postBlueprint(blueprint: blueprintToPost);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to save new blueprint.',
        );
        return;
      }

      // Get blueprint(with redeemRules)
      final Blueprint newBlueprint;
      try {
        newBlueprint = await owner_apis.getBlueprint(id: newBlueprintId);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get newly created blueprint information.',
        );
        return;
      }
      // TODO: ownerPropagateBlueprint(newBlueprint);

      if (store.blueprints == null) {
        // Blueprints not fetched. Just create set and add new blueprint.
        final newStore = store.copyWith(blueprints: {newBlueprint});
        // TODO: ownerPropagateStore(newStore);
      } else {
        store.blueprints!.add(newBlueprint);
        // TODO: ownerPropagateStore(store);
      }

      Carol.showTextSnackBar(
        text: 'Blueprint created!',
        level: SnackBarLevel.success,
      );
    } else {
      // BlueprintDesignMode.modify
      // PUT blueprint
      final blueprintToPut = Blueprint(
        id: widget.blueprint!.id,
        isDeleted: false,
        displayName: _displayName,
        description: _description,
        stampGrantCondDescription: _stampGrantCondDescription,
        numMaxStamps: _numMaxStamps,
        lastModifiedDate: DateTime.now(),
        expirationDate: _expirationDate!,
        numMaxRedeems: _numMaxRedeems,
        numMaxIssuesPerCustomer: _numMaxIssuesPerCustomer,
        numMaxIssues: _numMaxIssues,
        bgImageUrl: null,
        isPublishing: _isPublishing,
        store: null,
        storeId: store.id,
        redeemRules: _redeemRules.toSet(),
      );
      try {
        await owner_apis.putBlueprint(
          id: widget.blueprint!.id,
          blueprint: blueprintToPut,
        );
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to modify blueprint.',
        );
        return;
      }

      // Get blueprint
      final Blueprint modifiedBlueprint;
      try {
        modifiedBlueprint =
            await owner_apis.getBlueprint(id: widget.blueprint!.id);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get modified blueprint information.',
        );
        return;
      }
      // TODO: ownerPropagateBlueprint(modifiedBlueprint);

      if (store.blueprints == null) {
        // Blueprints not fetched. Just create set and add new blueprint.
        final newStore = store.copyWith(blueprints: {modifiedBlueprint});
        // TODO: ownerPropagateStore(newStore);
      } else {
        final newStore = store.copyWith(
          blueprints: <Blueprint>{modifiedBlueprint, ...store.blueprints!},
        );
        // TODO: ownerPropagateStore(newStore);
      }

      Carol.showTextSnackBar(
        text: 'Blueprint Modified!',
        level: SnackBarLevel.success,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onPressSelectExpDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    // Show date picker
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (selectedDate == null) {
      return;
    }

    if (!mounted) return;
    final selectedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (selectedTime == null) {
      return;
    }

    if (!mounted) return;
    setState(() {
      final target = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      _expirationDate = target;
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
