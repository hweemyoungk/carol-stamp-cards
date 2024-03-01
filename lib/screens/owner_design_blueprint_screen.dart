import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/user.dart';
import 'package:carol/params/app.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/blueprint_dialog_screen.dart';
import 'package:carol/screens/owner_design_redeem_rule_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/alert_row.dart';
import 'package:carol/widgets/common/icon_button_in_progress.dart';
import 'package:carol/widgets/common/proceed_alert_dialog.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool isSavingBlueprint = false;

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
  final List<Widget> _addRedeemRuleAlertRows = [];
  var _status = BlueprintDesignStatus.userInput;
  bool? _canAddRedeemRule;
  bool _isSetInfiniteNumMaxIssues = false;

  final _formKey = GlobalKey<FormState>();
  late String _displayName;
  late String _description;
  late String _stampGrantCondDescription;
  late TextEditingController _maxStampController;
  late int _numMaxStamps;
  late int _numMaxRedeems;
  late int _numMaxIssuesPerCustomer;
  late int _numMaxIssues;
  final List<RedeemRule> _redeemRules = [];
  List<bool>? _illegalRedeemRules;
  DateTime? _expirationDate;
  // late String? _bgImageUrl;
  bool _isPublishing = true;

  @override
  void initState() {
    super.initState();
    _maxStampController =
        TextEditingController(text: widget.blueprint?.numMaxStamps.toString());
    if (widget.blueprint != null) {
      final blueprint = widget.blueprint!;
      // Set _isSetInfiniteNumMaxIssues
      _isSetInfiniteNumMaxIssues = blueprint.numMaxIssues == 0;
      // Set _isPublishing
      _isPublishing = blueprint.isPublishing;
      // Set _expirationDate
      _expirationDate = blueprint.expirationDate;
      // Set _redeemRules
      // RedeemRules must be fetched in _BlueprintDialogScreenState._onPressModify
      _redeemRules.addAll(blueprint.redeemRules!);
    }
    _checkCanAddRedeemRule();
  }

  @override
  void dispose() {
    _maxStampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onBackgroundTernary = Theme.of(context).colorScheme.onBackground;
    // final onBackgroundTernary = widget.designMode == BlueprintDesignMode.modify
    //     ? Theme.of(context).colorScheme.onBackground.withOpacity(0.4)
    //     : Theme.of(context).colorScheme.onBackground;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designMode == BlueprintDesignMode.create
            ? 'New Blueprint'
            : 'Modify Blueprint'),
        actions: [
          IconButton(
            onPressed: _onPressAboutBlueprint,
            icon: const Icon(Icons.help),
          ),
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
                        maxLength: 30,
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
                              value.trim().isEmpty ||
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
                        enabled:
                            widget.designMode == BlueprintDesignMode.create,
                        initialValue:
                            widget.blueprint?.stampGrantCondDescription,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(
                                  widget.designMode ==
                                          BlueprintDesignMode.create
                                      ? 1.0
                                      : 0.5,
                                )),
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
                                    int.tryParse(value) == null) {
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
                                  'Max Redeems per Card',
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
                                  return 'Must be in 1~100';
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
                              decoration: InputDecoration(
                                label: Text(
                                  'Max Issues per Customer',
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // late int _numMaxIssues;
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  enabled: !_isSetInfiniteNumMaxIssues,
                                  initialValue:
                                      widget.blueprint?.numMaxIssues.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground
                                              .withOpacity(
                                                  _isSetInfiniteNumMaxIssues
                                                      ? 0.5
                                                      : 1.0)),
                                  decoration: InputDecoration(
                                    label: Text(
                                      'Max Total Issues',
                                      style: TextStyle(
                                        color: onBackgroundTernary,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (_isSetInfiniteNumMaxIssues) {
                                      return null;
                                    }

                                    if (value == null ||
                                        int.tryParse(value) == null ||
                                        int.parse(value) < 1) {
                                      return 'Must be 1+ integer';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  onSaved: (newValue) {
                                    if (_isSetInfiniteNumMaxIssues) {
                                      _numMaxIssues = 0;
                                      return;
                                    }
                                    _numMaxIssues = int.parse(newValue!);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  Switch(
                                    value: _isSetInfiniteNumMaxIssues,
                                    onChanged: (value) {
                                      setState(() {
                                        _isSetInfiniteNumMaxIssues = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Infinite',
                                    style: TextStyle(
                                      color: onBackgroundTernary,
                                    ),
                                  ),
                                ],
                              )
                            ],
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
                          onPressed: _canAddRedeemRule == null
                              ? null
                              : _canAddRedeemRule!
                                  ? _onPressAddRedeemRule
                                  : _onPressAddRedeemRuleViolated,
                          icon: Icon(
                            Icons.add_box,
                            color:
                                _canAddRedeemRule == null || _canAddRedeemRule!
                                    ? Theme.of(context).colorScheme.onBackground
                                    : Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withOpacity(0.5),
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
                                    if (outputRedeemRule.isDeleted) {
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
                                      formatDateTime(_expirationDate!),
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
                            onPressed: _onPressSelectExpDate,
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

  Future<bool> _checkMembershipBlueprints() async {
    final user = ref.read(currentUserProvider)!;
    final violated =
        await _violatedNumMaxCurrentActiveBlueprintsPerStore(user: user);
    return !violated;
  }

  /// Checks <code>@Min(-1) numMaxCurrentActiveBlueprintsPerStore</code>.<br>
  /// Currently, inactive blueprint means not publishing blueprint.<br>
  /// Expired blueprint can be either active or inactive.
  Future<bool> _violatedNumMaxCurrentActiveBlueprintsPerStore({
    required User user,
  }) async {
    // Check infinity
    final numMaxCurrentActiveBlueprintsPerStore =
        user.ownerMembership!.numMaxCurrentActiveBlueprintsPerStore;
    if (numMaxCurrentActiveBlueprintsPerStore == -1) return false;

    final blueprints = ref.read(ownerStoreScreenStoreProvider)?.blueprints;
    if (blueprints == null) {
      Carol.showTextSnackBar(
        text:
            'Failed to get number of current active(i.e. publishing) blueprints per store.',
        level: SnackBarLevel.error,
      );
      return true;
    }

    final numCurrentActiveBlueprintsPerStore =
        blueprints.where((blueprint) => blueprint.isPublishing).length;
    final bool violated;
    if (widget.designMode == BlueprintDesignMode.create) {
      // Create: numMax <= num
      violated = numMaxCurrentActiveBlueprintsPerStore <=
          numCurrentActiveBlueprintsPerStore;
    } else {
      // Modify: numMax < num - 1 + (whether _isPublishing)
      violated = numMaxCurrentActiveBlueprintsPerStore <
          numCurrentActiveBlueprintsPerStore - 1 + (_isPublishing ? 1 : 0);
    }
    if (violated) {
      Carol.showTextSnackBar(
        text:
            'Reachedmax of current active(i.e. publishing) blueprints per store.',
        level: SnackBarLevel.error,
      );
    }
    return violated;
  }

  Future<void> _saveBlueprint() async {
    if (!_validateInput() || !await _checkMembershipBlueprints()) {
      return;
    }

    // Proceed alert
    final title = widget.designMode == BlueprintDesignMode.create
        ? const Text('Create Blueprint?')
        : const Text('Modify Blueprint?');
    final content = widget.designMode == BlueprintDesignMode.create
        ? _isPublishing
            ? const Text(
                'This will take up 1 active blueprint of current store.')
            : const Text('This will take up 1 blueprint of current store.')
        : null;
    final proceedButtonString =
        widget.designMode == BlueprintDesignMode.create ? 'Create' : 'Modify';

    if (!mounted) return;
    final proceed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) {
        return ProceedAlertDialog(
          title: title,
          content: content,
          proceedButtonString: proceedButtonString,
        );
      },
    );
    if (proceed == null || !proceed) {
      return;
    }

    // Save
    isSavingBlueprint = true;
    final storesNotifier = ref.read(ownerStoresListStoresProvider.notifier);
    final storeNotifier = ref.read(ownerStoreScreenStoreProvider.notifier);
    final blueprintNotifier =
        ref.read(ownerBlueprintDialogScreenBlueprintProvider.notifier);

    _formKey.currentState!.save();

    final watchedStore = ref.read(ownerStoreScreenStoreProvider);
    if (watchedStore?.blueprints == null) {
      Carol.showTextSnackBar(
        text: 'Missing store data... Please refresh and start over.',
        level: SnackBarLevel.error,
      );
      isSavingBlueprint = false;
      return;
    }

    final store = watchedStore!;

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
        if (mounted) {
          setState(() {
            _status = BlueprintDesignStatus.userInput;
          });
        }
        isSavingBlueprint = false;
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
        if (mounted) {
          setState(() {
            _status = BlueprintDesignStatus.userInput;
          });
        }
        isSavingBlueprint = false;
        return;
      }

      // Propagate
      final storeToRefresh = store.copyWith(blueprints: <Blueprint>{
        newBlueprint,
        ...store.blueprints!,
      });
      // ownerStoresListStoresProvider
      storesNotifier.replaceIfIdMatch(storeToRefresh);
      // ownerStoreScreenStoreProvider
      storeNotifier.set(storeToRefresh);

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
        if (mounted) {
          setState(() {
            _status = BlueprintDesignStatus.userInput;
          });
        }
        isSavingBlueprint = false;
        return;
      }

      // Get blueprint
      Blueprint modifiedBlueprint;
      try {
        modifiedBlueprint =
            await owner_apis.getBlueprint(id: widget.blueprint!.id);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: 'Failed to get modified blueprint information.',
        );
        if (mounted) {
          setState(() {
            _status = BlueprintDesignStatus.userInput;
          });
        }
        isSavingBlueprint = false;
        return;
      }

      if (modifiedBlueprint.redeemRules == null) {
        // Fetch redeem rules
        final Set<RedeemRule> redeemRules;
        try {
          redeemRules = await owner_apis.listRedeemRules(
              blueprintId: modifiedBlueprint.id);
        } on Exception catch (e) {
          Carol.showExceptionSnackBar(
            e,
            contextMessage: 'Failed to get redeem rules',
          );
          if (mounted) {
            setState(() {
              _status = BlueprintDesignStatus.userInput;
            });
          }
          isSavingBlueprint = false;
          return;
        }
        modifiedBlueprint =
            modifiedBlueprint.copyWith(redeemRules: redeemRules);
      }

      // Propagate
      final storeToRefresh = store.copyWith(blueprints: <Blueprint>{
        modifiedBlueprint,
        ...store.blueprints!,
      });
      // ownerStoresListStoresProvider
      storesNotifier.replaceIfIdMatch(storeToRefresh);
      // ownerStoreScreenStoreProvider
      storeNotifier.set(storeToRefresh);
      // ownerBlueprintDialogScreenBlueprintProvider
      blueprintNotifier.set(modifiedBlueprint);

      Carol.showTextSnackBar(
        text: 'Blueprint Modified!',
        level: SnackBarLevel.success,
      );
    }
    isSavingBlueprint = false;
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onPressSelectExpDate() async {
    final now = DateTime.now();
    final firstDate = _getFirstDate(now);
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    // Show date picker
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? widget.blueprint?.expirationDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (selectedDate == null) {
      return;
    }

    if (!mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _expirationDate ?? widget.blueprint?.expirationDate ?? now,
      ),
    );
    if (selectedTime == null) {
      return;
    }

    if (!mounted) return;
    final target = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (target.isBefore(firstDate)) {
      Carol.showTextSnackBar(
        text:
            'Expiration date must be after ${formatDateTime(firstDate)}.\nChoose date again.',
        level: SnackBarLevel.error,
        seconds: 10,
      );
      return;
    }
    setState(() {
      _expirationDate = target;
    });
  }

  DateTime _getFirstDate(DateTime now) {
    if (widget.designMode == BlueprintDesignMode.create) {
      return now;
    }

    final minExpirationDate = now.add(
      const Duration(
        seconds: modifyBlueprintExpDateMinRemainingFromNowInSeconds,
      ),
    );
    var curExpirationDate = widget.blueprint!.expirationDate;

    // Return min(sevenDaysAfterNow, curExpirationDate)
    return minExpirationDate.compareTo(curExpirationDate) < 0
        ? minExpirationDate
        : curExpirationDate;
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
    Carol.showTextSnackBar(
      text: 'This will take up 1 redeem rule of current blueprint.',
      level: SnackBarLevel.info,
    );

    if (!mounted) return;
    setState(() {
      _redeemRules.add(newRedeemRule);
      _checkCanAddRedeemRule();
    });
  }

  Future<void> _checkCanAddRedeemRule() async {
    final user = ref.read(currentUserProvider)!;

    setState(() {
      _addRedeemRuleAlertRows.clear();
      _canAddRedeemRule = null;
    });

    final violatedNumMaxCurrentTotalRedeemRulesPerBlueprintTask =
        _violatedNumMaxCurrentTotalRedeemRulesPerBlueprint(user: user);
    final violatedNumMaxCurrentActiveRedeemRulesPerBlueprintTask =
        _violatedNumMaxCurrentActiveRedeemRulesPerBlueprint(user: user);
    final tasks = [
      violatedNumMaxCurrentTotalRedeemRulesPerBlueprintTask,
      violatedNumMaxCurrentActiveRedeemRulesPerBlueprintTask,
    ];
    final violations = await Future.wait(tasks);
    if (violations.every((violated) => !violated)) {
      if (mounted) {
        setState(() {
          _canAddRedeemRule = true;
        });
      }
    }
  }

  /// Checks <code>@Min(-1) numMaxCurrentTotalBlueprintsPerStore</code>.
  Future<bool> _violatedNumMaxCurrentTotalRedeemRulesPerBlueprint({
    required User user,
  }) async {
    // Check infinity
    final numMaxCurrentTotalRedeemRulesPerBlueprint =
        user.ownerMembership!.numMaxCurrentTotalRedeemRulesPerBlueprint;
    if (numMaxCurrentTotalRedeemRulesPerBlueprint == -1) return false;

    final numCurrentTotalRedeemRulesPerBlueprint = _redeemRules.length;
    final violated = numMaxCurrentTotalRedeemRulesPerBlueprint <=
        numCurrentTotalRedeemRulesPerBlueprint;
    if (violated) {
      if (mounted) {
        setState(() {
          _canAddRedeemRule = false;
          _addRedeemRuleAlertRows.add(const AlertRow(
            text: 'Reached max of current total redeem rules per blueprint.',
          ));
        });
      }
    }
    return violated;
  }

  /// Checks <code>@Min(-1) numMaxCurrentActiveBlueprintsPerStore</code>.
  Future<bool> _violatedNumMaxCurrentActiveRedeemRulesPerBlueprint({
    required User user,
  }) async {
    // NO-OP: Currently, there's no active/inactive redeem rule.
    return false;
  }

  void _onPressAddRedeemRuleViolated() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cannot add redeem rule'),
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _addRedeemRuleAlertRows,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPressAboutBlueprint() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('About Blueprint'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Blueprint is the source of customer\'s card.',
                    style: Theme.of(context).textTheme.titleMedium),
                const Text(
                    '1. Following details can be modified without limit:'),
                const Text('  - Display Name'),
                const Text('  - Description'),
                const Text('  - Max Issues per Customer'),
                const Text('  - Max Total Issues'),
                const Text('  - Publish Now'),
                const Text('2. Stamp Grant Conditions cannot be modified.'),
                const Text('3. Following numbers cannot be decreased:'),
                const Text('  - Max Stamps'),
                const Text('  - Max Redeems per Card'),
                Text(
                    '4. Expiration Date can be modified but must always be after ${formatSeconds(modifyBlueprintExpDateMinRemainingFromNowInSeconds)} from now.'),
                const Text(
                    '5. Blueprint cannot be seen by customers if Publish Now is disabled but still be seen by those with already published card.'),
                const Text(
                  '6. Published cards so far are still active even if Publish Now is disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
