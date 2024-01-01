import 'package:carol/data/dummy_data.dart';
import 'package:carol/main.dart';
import 'package:carol/models/store.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/providers/stores_provider.dart';
import 'package:carol/utils.dart';
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
  // late IconData? _icon;
  // late String? _bgImageUrl;
  // late String? _profileImageUrl;
  // late String _ownerId;

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
                      padding: Utils.basicWidgetEdgeInsets(),
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
                      padding: Utils.basicWidgetEdgeInsets(),
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
                      padding: Utils.basicWidgetEdgeInsets(),
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
                      padding: Utils.basicWidgetEdgeInsets(),
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
                          padding: Utils.basicWidgetEdgeInsets(),
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
                          padding: Utils.basicWidgetEdgeInsets(),
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
    final ownerStoresNotifier = ref.read(ownerStoresProvider.notifier);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _status = StoreDesignStatus.sending;
    });
    _formKey.currentState!.save();

    if (widget.designMode == StoreDesignMode.create) {
      // TODO POST Store
      await Utils.delaySeconds(2);
      final location = uuid.v4();
      final newStore = Store(
        address: _address,
        description: _description,
        displayName: _displayName,
        id: location,
        lat: _lat,
        lng: _lng,
        ownerId: currentUser.id,
        phone: _phone,
        zipcode: _zipcode,
        bgImageUrl: null,
        icon: null,
        profileImageUrl: null,
      );
      ownerStoreProviders.tryAddProvider(entity: newStore);
      ownerStoresNotifier.prepend(newStore);
      ScaffoldMessenger.of(MyApp.materialKey.currentContext!)
          .showSnackBar(const SnackBar(
        content: Text('New Store Created!'),
        duration: Duration(seconds: 3),
      ));
    } else {
      // TODO PUT Store
      await Utils.delaySeconds(2);
      final modifiedStore = Store(
        address: _address,
        description: _description,
        displayName: _displayName,
        id: widget.store!.id,
        lat: _lat,
        lng: _lng,
        ownerId: currentUser.id,
        phone: _phone,
        zipcode: _zipcode,
        bgImageUrl: null,
        icon: null,
        profileImageUrl: null,
      );
      final provider =
          ownerStoreProviders.tryGetProvider(entity: modifiedStore);
      if (provider == null) {
        ScaffoldMessenger.of(MyApp.materialKey.currentContext!)
            .showSnackBar(const SnackBar(
          content: Text('Error: Invalid Store'),
          duration: Duration(seconds: 3),
        ));
      }
      ref.read(provider!.notifier).set(entity: modifiedStore);
      ScaffoldMessenger.of(MyApp.materialKey.currentContext!)
          .showSnackBar(const SnackBar(
        content: Text('Store Modified!'),
        duration: Duration(seconds: 3),
      ));
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
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
