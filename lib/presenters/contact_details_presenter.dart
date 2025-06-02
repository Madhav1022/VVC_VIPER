import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../entities/contact_entity.dart';
import '../interactors/contact_interactor.dart';

class ContactDetailsPresenter {
  final ContactInteractor _interactor = ContactInteractor();

  Future<ContactEntity> getContactById(int id) async {
    return await _interactor.getContactById(id);
  }

  Future<void> callContact(String phoneNumber, Function(String) showError) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showError('Cannot make call.');
    }
  }

  Future<void> emailContact(String email, Function(String) showError) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showError('Cannot send email.');
    }
  }

  Future<void> openMap(String address, Function(String) showError) async {
    final Uri url = Uri.parse(Platform.isAndroid
        ? 'geo:0,0?q=$address'
        : 'https://maps.apple.com/?q=$address');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showError('Cannot open map.');
    }
  }

  Future<void> openWebsite(String website, Function(String) showError) async {
    final Uri url = Uri.parse(website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showError('Cannot open website.');
    }
  }
}