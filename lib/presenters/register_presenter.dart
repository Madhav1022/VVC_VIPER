import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/register/register_view.dart';

class RegisterPresenter {
  late RegisterView _view;

  void attachView(RegisterView view) => _view = view;
  void detachView() {}

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Optionally update displayName:
      await cred.user?.updateDisplayName(name);

      _view.showMessage('Registration successful!');
      _view.navigateToLogin();
    } on FirebaseAuthException catch (e) {
      _view.showMessage(e.message ?? 'Registration failed');
    } catch (e) {
      _view.showMessage('An error occurred');
    }
  }
}
