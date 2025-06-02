import 'package:flutter/material.dart';

abstract class ContactDetailsView {
  void showError(String message);
  void refreshUI();
}