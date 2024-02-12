import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/store.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late String _zipcode;
  late String _address;
  late String _phone;
  late double _lat;
  late double _lng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designMode == StoreDesignMode.create
            ? 'New Store'
            : 'Modify Store'),
        actions: [
          _status == StoreDesignStatus.userInput
              ? IconButton(
                  onPressed: _saveStore,
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
                        initialValue: widget.store?.description,
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
                        initialValue: widget.store?.zipcode,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 8,
                        decoration: const InputDecoration(
                          label: Text('Zipcode'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().length <= 1 ||
                              value.trim().length > 8) {
                            return 'Must be between 1 and 8 characters long';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _zipcode = newValue!;
                        },
                      ),
                    ),
                    Padding(
                      padding: DesignUtils.basicWidgetEdgeInsets(),
                      child: TextFormField(
                        initialValue: widget.store?.address,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                        maxLength: 100,
                        decoration: const InputDecoration(
                          label: Text('Address'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().length <= 1 ||
                              value.trim().length > 100) {
                            return 'Must be between 1 and 100 characters long';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _address = newValue!;
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
                          if (value == null ||
                              value.trim().length <= 1 ||
                              value.trim().length > 15) {
                            return 'Must be between 1 and 15 characters long';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onSaved: (newValue) {
                          _phone = newValue!;
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
                              initialValue: widget.store?.lat.toString(),
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
                                if (value == null ||
                                    double.tryParse(value) == null ||
                                    90 < double.parse(value) ||
                                    double.parse(value) < -90) {
                                  return 'Must be valid float between -90 and 90';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onSaved: (newValue) {
                                _lat = double.parse(newValue!);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: DesignUtils.basicWidgetEdgeInsets(),
                          child: SizedBox(
                            width: 150,
                            child: TextFormField(
                              initialValue: widget.store?.lng.toString(),
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
                                if (value == null ||
                                    double.tryParse(value) == null ||
                                    180 < double.parse(value) ||
                                    double.parse(value) < -180) {
                                  return 'Must be valid float between -180 and 180';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onSaved: (newValue) {
                                _lng = double.parse(newValue!);
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

  void _saveStore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    if (!mounted) return;
    Navigator.of(context).pop();
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
