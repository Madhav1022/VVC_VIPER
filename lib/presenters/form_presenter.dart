import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/contact_entity.dart';
import '../interactors/contact_interactor.dart';
import '../routers/app_router.dart';
import '../utils/helper_functions.dart';

class FormPresenter {
  final ContactInteractor _interactor = ContactInteractor();
  final AppRouter _router = AppRouter();

  Future<void> saveContact(
      BuildContext context,
      ContactEntity contact,
      GlobalKey<FormState> formKey,
      ) async {
    if (!formKey.currentState!.validate()) return;

    try {
      // Locate the image file from CameraPage
      File? imageFile;
      if (contact.image.isNotEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        imageFile = File('${dir.path}/${contact.image}');
        if (!await imageFile.exists()) imageFile = null;
      }

      // Insert remotely + cache
      await _interactor.insertContact(contact, imageFile);

      showMsg(context, 'Saved');
      _router.navigateToHome(context);
    } catch (e) {
      showMsg(context, 'Failed to save: $e');
    }
  }
}

