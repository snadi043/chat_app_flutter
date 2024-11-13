import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/widgets/user_image.dart';

final firebaseAuth = FirebaseAuth.instance;

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() {
    return _AuthenticationState();
  }
}

class _AuthenticationState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _isAuthenticating = false;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userInputCredentials =
            await firebaseAuth.signInWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);
      } else {
        final userInputCredentials =
            await firebaseAuth.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        // print(userInputCredentials);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user-image')
            .child('${userInputCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection('users')
            .doc('${userInputCredentials.user!.uid}')
            .set({
          'username': 'to be implemented',
          'email': _enteredEmail,
          'image': imageUrl
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication Failed')));
      setState(() {
        _isAuthenticating = false;
      });
    }
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
                  bottom: 20, top: 30, left: 20, right: 20),
              width: 200,
              child: Image.asset('assets/images/chat.png'),
            ),
            Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImage(
                                onSelectedImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please Enter a Valid E-mail address';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                              decoration: const InputDecoration(
                                label: Text('E-mail address'),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password should be atleast 6 characters';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                              decoration: const InputDecoration(
                                label: Text('Password'),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  onPressed: _submit,
                                  child: Text(_isLogin ? 'Login' : 'Sign Up')),
                            if (!_isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create an account'
                                      : 'Already have an account ')),
                          ],
                        )),
                  ),
                ))
          ],
        ),
      )),
    );
  }
}
