import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnerDesignRedeemRuleScreen extends ConsumerStatefulWidget {
  const OwnerDesignRedeemRuleScreen({
    super.key,
    required this.designMode,
    required this.blueprint,
    this.redeemRule,
  });
  final RedeemRuleDesignMode designMode;
  final Blueprint? blueprint;
  final RedeemRule? redeemRule;

  @override
  ConsumerState<OwnerDesignRedeemRuleScreen> createState() =>
      _OwnerDesignRedeemRuleScreenState();
}

class _OwnerDesignRedeemRuleScreenState
    extends ConsumerState<OwnerDesignRedeemRuleScreen> {
  final _formKey = GlobalKey<FormState>();
  late AppLocalizations _localizations;
  late String _displayName;
  late String _description;
  late int _consumes;
  // late String _blueprintId;
  // late IconData? _icon;
  // late String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.redeemRule != null) {
      final redeemRule = widget.redeemRule!;
      _displayName = redeemRule.displayName;
      _description = redeemRule.description;
      _consumes = redeemRule.consumes;
    }
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designMode == RedeemRuleDesignMode.create
            ? _localizations.newRedeemRuleAppBarTitle
            : _localizations.modifyRedeemRuleAppBarTitle),
        actions: [
          IconButton(
            onPressed: _onPressAboutRedeemRule,
            icon: const Icon(Icons.help),
          ),
          if (widget.redeemRule?.id == -1)
            IconButton(
              onPressed: _locallyDeleteRedeemRule,
              icon: const Icon(Icons.delete),
            ),
          IconButton(
            onPressed: _locallySaveRedeemRule,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            // final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            // final editConsumesEnabled =
            //     widget.designMode == RedeemRuleDesignMode.create ||
            //         widget.redeemRule!.id == -1;
            const editConsumesEnabled = true;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: DesignUtils.basicWidgetEdgeInsets(),
                    child: TextFormField(
                      initialValue: widget.redeemRule?.displayName,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground),
                      maxLength: 50,
                      decoration: InputDecoration(
                        label: Text(_localizations.displayName),
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
                    child: TextFormField(
                      initialValue: widget.redeemRule?.description,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground),
                      maxLength: 1000,
                      decoration: InputDecoration(
                        label: Text(_localizations.description),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            value.trim().length > 1000) {
                          return _localizations.textLengthViolationMessage(
                              1, 1000);
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _description = newValue!;
                      },
                    ),
                  ),
                  // late int _consumes; // Can be modified
                  Padding(
                    padding: DesignUtils.basicWidgetEdgeInsets(),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 100,
                        child: TextFormField(
                          enabled: editConsumesEnabled,
                          initialValue: widget.redeemRule?.consumes.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                // color: editConsumesEnabled
                                //     ? Theme.of(context)
                                //         .colorScheme
                                //         .onBackground
                                //     : Theme.of(context)
                                //         .colorScheme
                                //         .onBackground
                                //         .withOpacity(0.4)),
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                          decoration: InputDecoration(
                            label: Text(_localizations.consumes),
                            suffixText: _localizations.stamps,
                            suffixStyle: TextStyle(
                              // color: editConsumesEnabled
                              //     ? Theme.of(context).colorScheme.onBackground
                              //     : Theme.of(context)
                              //         .colorScheme
                              //         .onBackground
                              //         .withOpacity(0.4)),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                int.tryParse(value) == null ||
                                int.parse(value) < 0) {
                              return _localizations
                                  .integerLowerboundViolationMessage(0);
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          onSaved: (newValue) {
                            _consumes = int.parse(newValue!);
                          },
                        ),
                      ),
                    ),
                  ),
                  // late String _blueprintId;
                  // late IconData? _icon;
                  // late String? _imageUrl;
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _locallySaveRedeemRule() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (widget.designMode == RedeemRuleDesignMode.create) {
      // Create
      final newRedeemRule = RedeemRule(
        id: -1,
        isDeleted: false,
        displayName: _displayName,
        description: _description,
        consumes: _consumes,
        imageId: null,
        blueprint: null,
        blueprintId: widget.blueprint?.id ?? -1,
        redeems: null,
      );
      Navigator.of(context).pop(newRedeemRule);
    } else {
      // Modify
      final modifiedRedeemRule = widget.redeemRule!.copyWith(
        displayName: _displayName,
        description: _description,
        consumes: _consumes,
      );
      Navigator.of(context).pop(modifiedRedeemRule);
    }
  }

  void _locallyDeleteRedeemRule() {
    // widget.redeemRule must exist
    final deletedRedeemRule = widget.redeemRule!.copyWith(isDeleted: true);
    Navigator.of(context).pop(deletedRedeemRule);
  }

  void _onPressAboutRedeemRule() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('About Redeem Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_localizations.whatIsRedeemRule,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  _localizations.redeemRuleExplanationItem1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_localizations.redeemRuleExplanationItem2),
                Text(_localizations.redeemRuleExplanationItem3),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum RedeemRuleDesignMode {
  create,
  modify,
}
