import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/contact_entity.dart';
import '../routers/app_router.dart';
import '../utils/constants.dart';

class CameraPresenter {
  final AppRouter _router = AppRouter();

  bool _isScanOver = false;
  List<String> _lines = [];
  String _name = '', _mobile = '', _email = '', _company = '', _designation = '', _address = '', _website = '', _image = '';

  // Getters
  bool get isFormValid => _name.isNotEmpty && _mobile.isNotEmpty && _email.isNotEmpty;
  bool get isScanOver => _isScanOver;
  List<String> get lines => _lines;

  // Process image from camera or gallery
  Future<void> processImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      try {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';

        final File newImage = await File(pickedFile.path).copy(newPath);
        _image = fileName;

        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final recognizedText = await textRecognizer.processImage(InputImage.fromFile(newImage));

        final tempList = <String>[];
        for (var block in recognizedText.blocks) {
          for (var line in block.lines) {
            tempList.add(line.text);
          }
        }

        _lines = tempList;
        _isScanOver = true;
        return;
      } catch (e) {
        print('Error processing image: $e');
        return;
      }
    }
  }

  // Update property values
  void updatePropertyValue(String property, String value) {
    switch (property) {
      case ContactProperties.name:
        _name = _name.isEmpty ? value : "$_name $value";
        break;
      case ContactProperties.mobile:
        _mobile = _mobile.isEmpty ? value : "$_mobile $value";
        break;
      case ContactProperties.email:
        _email = _email.isEmpty ? value : "$_email, $value";
        break;
      case ContactProperties.company:
        _company = _company.isEmpty ? value : "$_company $value";
        break;
      case ContactProperties.designation:
        _designation = _designation.isEmpty ? value : "$_designation $value";
        break;
      case ContactProperties.address:
        _address = _address.isEmpty ? value : "$_address, $value";
        break;
      case ContactProperties.website:
        _website = _website.isEmpty ? value : "$_website, $value";
        break;
    }
  }

  // Create contact and navigate to form
  void createContact(BuildContext context) {
    final contact = ContactEntity(
      name: _name,
      mobile: _mobile,
      email: _email,
      address: _address,
      company: _company,
      designation: _designation,
      website: _website,
      image: _image,
    );
    _router.navigateToForm(context, contact);
  }
}
