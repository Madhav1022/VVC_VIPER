import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../interactors/auth_interactor.dart';
import '../views/login/login_view.dart';

class LoginPresenter {
  late LoginView _view;
  final AuthInteractor _interactor = AuthInteractor();

  void attachView(LoginView view)   => _view = view;
  void detachView()                 {}

  Future<void> login({
    required String email,
    required String password,
    required GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) return;

    try {
      await _interactor.signIn(email: email, password: password);
      _view.showMessage('Login successful');
      _view.navigateToHome();
    } on FirebaseAuthException catch (e) {
      _view.showMessage(e.message ?? 'Login failed');
    } catch (_) {
      _view.showMessage('An unexpected error occurred');
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    try {
      await _interactor.sendPasswordReset(email);
      _view.showMessage('Reset email sent');
      _view.navigateToForgotPassword(email);
    } on FirebaseAuthException catch (e) {
      _view.showMessage(e.message ?? 'Could not send reset email');
    }
  }
}
