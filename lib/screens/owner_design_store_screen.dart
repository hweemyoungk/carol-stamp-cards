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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designMode == StoreDesignMode.create
            ? 'New Store'
            : 'Modify Store'),
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
                        decoration: const InputDecoration(
                          label: RequiredFieldLabel(
                            Text('Display Name'),
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
                        initialValue: widget.store?.description,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          label: RequiredFieldLabel(
                            Text('Description'),
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
                        initialValue: widget.store?.zipcode,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 7,
                        decoration: const InputDecoration(
                          label: Text('Zipcode'),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          if (value.trim().isEmpty || value.trim().length > 7) {
                            return 'Must be between 1 and 7 characters long';
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
                        decoration: const InputDecoration(
                          label: Text('Address'),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          if (value.trim().isEmpty ||
                              value.trim().length > 120) {
                            return 'Must be between 1 and 120 characters long';
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
                        decoration: const InputDecoration(
                          label: Text('Phone'),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          if (value.trim().isEmpty ||
                              value.trim().length > 15) {
                            return 'Must be between 1 and 15 characters long';
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
                              decoration: const InputDecoration(
                                label: Text('Latitude'),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(value) == null ||
                                    90 < double.parse(value) ||
                                    double.parse(value) < -90) {
                                  return 'Must be valid float between -90 and 90';
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
                              decoration: const InputDecoration(
                                label: Text('Longitude'),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(value) == null ||
                                    180 < double.parse(value) ||
                                    double.parse(value) < -180) {
                                  return 'Must be valid float between -180 and 180';
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
        ? const Text('Create Store?')
        : const Text('Modify Store?');
    final content = widget.designMode == StoreDesignMode.create
        ? const Text('This will take up 1 active store.')
        : null;
    final proceedButtonString =
        widget.designMode == StoreDesignMode.create ? 'Create' : 'Modify';
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
          contextMessage: 'Failed to save new store.',
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
          contextMessage: 'Failed to get newly create store information.',
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
        text: 'New store created!',
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
          contextMessage: 'Failed to modify store.',
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
        text: 'Store modified!',
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
          title: const Text('About Store'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Store is where you design and distribute your own blueprints.',
                    style: Theme.of(context).textTheme.titleMedium),
                const Text('1. Newly created store is active.'),
                const Text(
                    '2. Store has its own Store QR to share its detail with customers.'),
                const Text(
                    '3. Active store\'s every detail can be modified without limit.'),
                const Text('4. Active store can define blueprints.'),
                const Text(
                    '5. Active store can be closed if there is no active blueprint in the store.'),
                const Text('6. Closed store cannot be activated again.'),
                const Text('7. Closed store\'s details cannot be modified.'),
                const Text('8. Closed store still can be seen to customers.'),
                Text(
                    '9. Closed store is automatically deleted in ${formatSeconds(app_params.softDeleteClosedStoreInSeconds)}.'),
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
