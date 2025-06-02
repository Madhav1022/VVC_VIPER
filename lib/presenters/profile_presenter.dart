import 'package:flutter/material.dart';
import '../interactors/auth_interactor.dart';
import '../views/profile/profile_view.dart';

class ProfilePresenter {
  late ProfileView _view;
  final AuthInteractor _auth = AuthInteractor();

  void attachView(ProfileView view) => _view = view;
  void detachView() {}

  String get currentEmail =>
      _auth.getCurrentUser()?.email ?? '';

  String get currentDisplayName =>
      _auth.getCurrentUser()?.displayName ?? '';

  Future<void> updateProfile(String newName) async {
    try {
      await _auth.updateProfile(displayName: newName);
      _view.showMessage('Profile updated');
      _view.refreshUI();
    } catch (e) {
      _view.showMessage(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _view.navigateBack();
  }
}
