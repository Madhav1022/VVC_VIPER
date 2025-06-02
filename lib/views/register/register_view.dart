import 'package:flutter/material.dart';

/// The interface our Presenter will call on success/failure
abstract class RegisterView {
  void showMessage(String message);
  void navigateToLogin();
}
