import 'package:flutter/material.dart';
import '../interactors/auth_interactor.dart';
import '../views/forgot_password/forgot_password_view.dart';

class ForgotPasswordPresenter {
  late ForgotPasswordView _view;
  final AuthInteractor _interactor = AuthInteractor();

  void attachView(ForgotPasswordView view) => _view = view;
  void detachView() {}

  Future<void> resetPassword({
    required String email,
  }) async {
    if (email.isEmpty) {
      _view.showMessage('Please enter your email');
      return;
    }

    try {
      await _interactor.sendPasswordReset(email);
      _view.showMessage('Password reset link sent to $email');
      _view.navigateToLogin();
    } catch (e) {
      _view.showMessage(e.toString());
    }
  }
}
