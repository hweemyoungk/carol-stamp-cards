import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/store.dart';
import 'package:carol/params/app.dart' as app_params;
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/proceed_alert_dialog.dart';
import 'package:carol/widgets/common/required_field_label.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool isSavingStore = false;

class OwnerDesignStoreScreen extends ConsumerStatefulWidget {
  const OwnerDesignStoreScreen({
    super.key,
    required this.designMode,
    this.store,
  });
  final StoreDesignMode designMode;
  final Store? store;

  @override
  ConsumerState<OwnerDesignStoreScreen> createState() =>
      _OwnerDesignStoreScreenState();
}

class _OwnerDesignStoreScreenState
    extends ConsumerState<OwnerDesignStoreScreen> {
  late AppLocalizations _localizations;
  var _status = StoreDesignStatus.userInput;
  final _formKey = GlobalKey<FormState>();
  late String _displayName;
  late String _description;
  late String? _zipcode;
  late String? _address;
  late String? _phone;
  late double? _lat;
  late double? _lng;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designMode == StoreDesignMode.create
            ? _localizations.newStoreAppBarTitle
            : _localizations.modifyStoreAppBarTitle),
        actions: [
          IconButton(
            onPressed: _onPressAboutStore,
            icon: const Icon(Icons.help),
          ),
          _status == StoreDesignStatus.userInput
              ? IconButton(
                  onPressed: _onPressSave,
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
              // final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: DesignUtils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue: widget.store?.displayName,
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
                      child: TextFormField(
                        initialValue: widget.store?.description,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 1000,
                        decoration: InputDecoration(
                          label: RequiredFieldLabel(
                            Text(_localizations.description),
                          ),
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
                    Padding(
                      padding: DesignUtils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue: widget.store?.zipcode,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 7,
                        decoration: InputDecoration(
                          label: Text(_localizations.zipcode),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          if (value.trim().length > 7) {
                            return _localizations.textLengthViolationMessage(
                                0, 7);
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _zipcode = newValue;
                        },
                      ),
                    ),
                    Padding(
                      padding: DesignUtils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue: widget.store?.address,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 120,
                        decoration: InputDecoration(
                          label: Text(_localizations.address),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          if (value.trim().length > 120) {
                            return _localizations.textLengthViolationMessage(
                                0, 120);
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _address = newValue;
                        },
                      ),
                    ),
                    // String _phone;
                    Padding(
                      padding: DesignUtils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue: widget.store?.phone,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 15,
                        decoration: InputDecoration(
                          label: Text(_localizations.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          if (value.trim().length > 15) {
                            return _localizations.textLengthViolationMessage(
                                0, 15);
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onSaved: (newValue) {
                          _phone = newValue;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // double _lat;
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 150,
                            child: TextFormField(
                              initialValue: widget.store?.lat?.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                              decoration: InputDecoration(
                                label: Text(_localizations.latitude),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(value) == null ||
                                    90 < double.parse(value) ||
                                    double.parse(value) < -90) {
                                  return _localizations
                                      .floatRangeViolationMessage(-90.0, 90.0);
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onSaved: (newValue) {
                                _lat = newValue == null || newValue.isEmpty
                                    ? null
                                    : double.parse(newValue);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 150,
                            child: TextFormField(
                              initialValue: widget.store?.lng?.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                              // double _lng;
                              decoration: InputDecoration(
                                label: Text(_localizations.longitude),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(value) == null ||
                                    180 < double.parse(value) ||
                                    double.parse(value) < -180) {
                                  return _localizations
                                      .floatRangeViolationMessage(
                                          -180.0, 180.0);
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onSaved: (newValue) {
                                _lng = newValue == null || newValue.isEmpty
                                    ? null
                                    : double.parse(newValue);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // IconData? _icon;
                    // String? _bgImageUrl;
                    // String? _profileImageUrl;
                    // String _ownerId;
                  ],
                ),
              );
            },
          )),
    );
  }

  Future<void> _onPressSave() async {
    _saveStore();
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Proceed alert
    final title = widget.designMode == StoreDesignMode.create
        ? Text(_localizations.createStoreAlertTitle)
        : Text(_localizations.modifyStoreAlertTitle);
    final content = widget.designMode == StoreDesignMode.create
        ? Text(_localizations.createStoreAlertContent)
        : null;
    final proceedButtonString = widget.designMode == StoreDesignMode.create
        ? _localizations.create
        : _localizations.modify;
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

    isSavingStore = true;
    final currentUser = ref.read(currentUserProvider)!;
    final storesNotifier = ref.read(ownerStoresListStoresProvider.notifier);
    final storeNotifier = ref.read(ownerStoreScreenStoreProvider.notifier);

    setState(() {
      _status = StoreDesignStatus.sending;
    });
    _formKey.currentState!.save();

    if (widget.designMode == StoreDesignMode.create) {
      // POST Store
      final storeToPost = Store(
        id: -1,
        isDeleted: false,
        address: _address,
        description: _description,
        displayName: _displayName,
        lat: _lat,
        lng: _lng,
        isClosed: false,
        isInactive: false,
        ownerId: currentUser.id,
        phone: _phone,
        zipcode: _zipcode,
        bgImageUrl: null,
        profileImageUrl: null,
        blueprints: null,
      );
      final int newId;
      try {
        newId = await owner_apis.postStore(store: storeToPost);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: _localizations.failedToSaveNewStore,
          localizations: _localizations,
        );
        if (mounted) {
          setState(() {
            _status = StoreDesignStatus.userInput;
          });
        }
        isSavingStore = false;
        return;
      }

      // Get Store
      final Store newStore;
      try {
        newStore = await owner_apis.getStore(id: newId);
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: _localizations.failedToLoadNewlyCreatedStore,
          localizations: _localizations,
        );
        if (mounted) {
          setState(() {
            _status = StoreDesignStatus.userInput;
          });
        }
        isSavingStore = false;
        return;
      }

      // Propagate
      // ownerStoresListStoresProvider
      storesNotifier.replaceOrPrepend(newStore);

      Carol.showTextSnackBar(
        text: _localizations.createStoreSuccess,
        level: SnackBarLevel.success,
      );
    } else {
      // StoreDesignMode.modify

      // PUT Store
      final storeToPut = widget.store!.copyWith(
        address: _address,
        description: _description,
        displayName: _displayName,
        lat: _lat,
        lng: _lng,
        phone: _phone,
        zipcode: _zipcode,
      );
      try {
        await owner_apis.putStore(
          id: storeToPut.id,
          store: storeToPut.copyWith(
            blueprints: null, // Don't send blueprints
          ),
        );
      } on Exception catch (e) {
        Carol.showExceptionSnackBar(
          e,
          contextMessage: _localizations.failedToModifyStore,
          localizations: _localizations,
        );
        if (mounted) {
          setState(() {
            _status = StoreDesignStatus.userInput;
          });
        }
        isSavingStore = false;
        return;
      }

      // Get Store
      // final Store modifiedStore;
      // try {
      //   modifiedStore = await owner_apis.getStore(id: storeToPut.id);
      // } on Exception catch (e) {
      //   Carol.showExceptionSnackBar(
      //     e,
      //     contextMessage: 'Failed to get modified store information.',
      //   );
      //   return;
      // }
      final modifiedStore = storeToPut;

      // Propagate
      // ownerStoresListStoresProvider
      storesNotifier.replaceOrPrepend(modifiedStore);
      // ownerStoreScreenStoreProvider
      storeNotifier.set(modifiedStore);

      Carol.showTextSnackBar(
        text: _localizations.modifyStoreSuccess,
        level: SnackBarLevel.success,
      );
    }

    isSavingStore = false;
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onPressAboutStore() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(_localizations.aboutStoreDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_localizations.whatIsStore,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(_localizations.storeExplanationItem1),
                Text(_localizations.storeExplanationItem2),
                Text(_localizations.storeExplanationItem3),
                Text(_localizations.storeExplanationItem4),
                Text(_localizations.storeExplanationItem5),
                Text(_localizations.storeExplanationItem6),
                Text(_localizations.storeExplanationItem7),
                Text(_localizations.storeExplanationItem8),
                Text(_localizations.storeExplanationItem9(formatSeconds(
                  app_params.softDeleteClosedStoreInSeconds,
                  localizations: _localizations,
                ))),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum StoreDesignStatus {
  userInput,
  sending,
}

enum StoreDesignMode {
  create,
  modify,
}
