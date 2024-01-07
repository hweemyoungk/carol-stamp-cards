import 'dart:io';

import 'package:carol/data/dummy_data.dart';
import 'package:carol/models/user.dart';
import 'package:carol/providers/stamp_cards_init_loaded_provider.dart';
import 'package:carol/providers/stamp_cards_provider.dart';
import 'package:carol/screens/dashboard_screen.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isAutoSigningIn = true;
  var _isLogin = true;
  var _isAuthenticating = false;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    tryAutoSignIn();
  }

  Future<void> tryAutoSignIn() async {
    // 1. Get stored credential
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userCredential = prefs.getString('userCredential');
    if (userCredential == null) {
      if (mounted) {
        setState(() {
          _isAutoSigningIn = false;
        });
      }
    }
    // TODO: Implement tryAutoSignIn
    // 2. Validate credential
    // 3. Refresh to latest credential
    // 4. Get User and store
    // 5. Push replacement to DashboardScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: const Icon(
                  Icons.card_giftcard,
                  size: 150,
                ),
              ),
              _isAutoSigningIn
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : Card(
                      margin: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // if (!_isLogin)
                                //   UserImagePicker(
                                //     onPickImage: (pickedImageFile) {
                                //       _pickedImageFile = pickedImageFile;
                                //     },
                                //   ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  validator: (value) {
                                    final emailRegex = RegExp(
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !emailRegex.hasMatch(value)) {
                                      return 'Invalid email address';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _enteredEmail = newValue!;
                                  },
                                ),
                                if (!_isLogin)
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                    ),
                                    enableSuggestions: false,
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().length < 4) {
                                        return 'Must be 4+ chars long';
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      _enteredUsername = newValue!;
                                    },
                                  ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 6) {
                                      return 'Must be 6+ characters long';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _enteredPassword = newValue!;
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (_isAuthenticating)
                                  const CircularProgressIndicator(),
                                if (!_isAuthenticating)
                                  ElevatedButton(
                                    onPressed: _isLogin
                                        ? _onPressSignIn
                                        : _onPressSignUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                    child:
                                        Text(_isLogin ? 'Sign In' : 'Sign Up'),
                                  ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create an account'
                                      : 'I already have an account'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  /* void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (!_isLogin && _pickedImageFile == null) {
      return;
    }

    _formKey.currentState!.save();
    // print('Email: $_enteredEmail\tPassword: $_enteredPassword');

    setState(() {
      _isAuthenticating = true;
    });
    try {
      if (_isLogin) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        print(userCredential);
        // invalid-email:
        // user-disabled:
        // user-not-found:
        // wrong-password:
      } else {
        // Sign Up mode
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        await storageRef.putFile(_pickedImageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
      // email-already-in-use:
      // invalid-email:
      // operation-not-allowed:
      // weak-password:
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Authentication failed')));
      }
    }
  } */

  void _onPressSignUp() {}

  Future<void> _onPressSignIn() async {
    // TODO Implement
    // await apis.signInWithPassword(email: _enteredEmail, password: _enteredPassword);

    // Dummy
    // Set User
    currentUser = User(
      id: uuid.v4(),
      displayName: 'HMK',
      profileImageUrl: 'assets/images/schnitzel-3279045_1280.jpg',
    );

    // Load Init Entities
    _loadInitEntities();

    // Next Screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const DashboardScreen(),
    ));
  }

  Future<void> _loadInitEntities() async {
    // Landing page is CardsList, so init load Cards

    final stampCardsInitLoadedNotifier =
        ref.read(stampCardsInitLoadedProvider.notifier);
    final stampCardsNotifier = ref.read(stampCardsProvider.notifier);

    // TODO: Implement
    // Real: Bottom up
    // Cards
    // Blueprints and RedeemRules
    // Stores

    // Dummy: Top down
    await Utils.delaySeconds(2);
    // Stores
    final stores = genDummyCustomerStores(numStores: 2);
    // Blueprints and RedeemRules
    stores.forEach((store) {
      final blueprints = genDummyBlueprints(
        numBlueprints: 2,
        storeId: store.id,
      );
      blueprints.forEach((blueprint) {
        // StampCards
        final stampCards = genDummyStampCards(
          blueprint: blueprint,
          customerId: currentUser.id,
          numCards: 1,
        );
        stampCardsNotifier.appendAll(stampCards);
      });
    });
    stampCardsInitLoadedNotifier.set(true);
  }
}
