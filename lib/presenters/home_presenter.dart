import 'package:flutter/material.dart';
import '../entities/contact_entity.dart';
import '../interactors/contact_interactor.dart';
import '../routers/app_router.dart';
import '../interactors/auth_interactor.dart';

class HomePresenter {
  final ContactInteractor _interactor = ContactInteractor();
  final AuthInteractor    _auth        = AuthInteractor();
  final AppRouter _router = AppRouter();

  // Stream for contacts
  Stream<List<ContactEntity>> get contactStream => _interactor.contactStream;

  bool _showingFavorites = false;

  /// Delete a contact by id
  Future<void> deleteContact(int id) async {
    await _interactor.deleteContact(id);
  }

  /// Toggle favorite status and reload list
  Future<void> toggleFavorite(ContactEntity contact) async {
    await _interactor.toggleFavorite(contact.id, contact.favorite);
    if (_showingFavorites) {
      await _interactor.getFavoriteContacts();
    } else {
      await _interactor.getAllContacts();
    }
  }

  /// Load either all or favorite contacts
  void loadContacts({bool favorites = false}) {
    _showingFavorites = favorites;
    if (favorites) {
      _interactor.getFavoriteContacts();
    } else {
      _interactor.getAllContacts();
    }
  }

  /// Navigate to the "Add Contact" (camera) screen
  void navigateToAddContact(BuildContext context) {
    final newContact = ContactEntity(
      name: '',
      mobile: '',
      email: '',
      address: '',
      company: '',
      designation: '',
      website: '',
      image: '',
      favorite: false,
    );
    _router.navigateToCamera(context, newContact);
  }

  /// Navigate to contact details screen
  void navigateToContactDetails(BuildContext context, int id) {
    _router.navigateToDetails(context, id);
  }

  void dispose() {
    // nothing to dispose here
  }
  String get displayName => _auth.getCurrentUser()?.displayName ?? '';
}
