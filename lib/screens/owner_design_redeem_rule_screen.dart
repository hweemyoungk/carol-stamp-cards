import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerDesignRedeemRuleScreen extends ConsumerStatefulWidget {
  const OwnerDesignRedeemRuleScreen({
    super.key,
    required this.designMode,
    required this.blueprint,
    this.redeemRule,
  });
  final RedeemRuleDesignMode designMode;
  final StampCardBlueprint? blueprint;
  final RedeemRule? redeemRule;

  @override
  ConsumerState<OwnerDesignRedeemRuleScreen> createState() =>
      _OwnerDesignRedeemRuleScreenState();
}

class _OwnerDesignRedeemRuleScreenState
    extends ConsumerState<OwnerDesignRedeemRuleScreen> {
  final _formKey = GlobalKey<FormState>();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designMode == RedeemRuleDesignMode.create
            ? 'New Redeem Rule'
            : 'Modify Redeem Rule'),
        actions: [
          if (widget.redeemRule?.id == '')
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
            final editConsumesEnabled =
                widget.designMode == RedeemRuleDesignMode.create ||
                    widget.redeemRule!.id == '';
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
                    child: TextFormField(
                      initialValue: widget.redeemRule?.description,
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
                  // late int _consumes; // Should't be modified
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
                                  color: editConsumesEnabled
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                      : Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(0.4)),
                          decoration: InputDecoration(
                            label: const Text('Consumes'),
                            suffixText: 'stamps',
                            suffixStyle: TextStyle(
                                color: editConsumesEnabled
                                    ? Theme.of(context).colorScheme.onBackground
                                    : Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.4)),
                          ),
                          validator: (value) {
                            if (value == null ||
                                int.tryParse(value) == null ||
                                int.parse(value) < 0) {
                              return 'Must be 0+ integer';
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
        id: '',
        displayName: _displayName,
        description: _description,
        consumes: _consumes,
        icon: null,
        imageUrl: null,
        blueprintId: widget.blueprint?.id ?? '',
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
    final deletedRedeemRule = widget.redeemRule!.copyWith(blueprintId: '');
    Navigator.of(context).pop(deletedRedeemRule);
  }
}

enum RedeemRuleDesignMode {
  create,
  modify,
}
