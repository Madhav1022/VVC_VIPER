import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/db_helper.dart';
import '../entities/contact_entity.dart';
import '../interactors/auth_interactor.dart';
import 'firebase_storage_service.dart';
import '../utils/helper_functions.dart';

class ContactInteractor {
  static final ContactInteractor _instance = ContactInteractor._internal();
  factory ContactInteractor() => _instance;
  ContactInteractor._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final DbHelper _dbHelper = DbHelper();
  final AuthInteractor _auth = AuthInteractor();
  final _contactStreamController = StreamController<List<ContactEntity>>.broadcast();
  Stream<List<ContactEntity>> get contactStream => _contactStreamController.stream;

  /// Syncs all remote contacts into the stream & caches locally.
  Future<void> syncContactsFromRemote() async {
    final user = _auth.getCurrentUser();
    if (user == null) return;
    final uid = user.uid;

    // Measure Firestore fetch latency
    final startTime = DateTime.now();

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .get();

    final endTime = DateTime.now();
    final durationMs = endTime.difference(startTime).inMilliseconds;

    // Log Firestore latency
    await logLatency('Fetch All Contacts from Firestore', durationMs, source: 'Firestore');

    final List<ContactEntity> contacts = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final id = int.tryParse(doc.id) ?? DateTime.now().millisecondsSinceEpoch;
      final contact = ContactEntity(
        id: id,
        name: data['name'] ?? '',
        mobile: data['mobile'] ?? '',
        email: data['email'] ?? '',
        address: data['address'] ?? '',
        company: data['company'] ?? '',
        designation: data['designation'] ?? '',
        website: data['website'] ?? '',
        image: data['imageUrl'] ?? '',
        favorite: data['favorite'] == true,
      );
      contacts.add(contact);
      // Cache locally
      await _dbHelper.insertContact(contact);
    }
    _contactStreamController.add(contacts);
  }

  /// Public: load all contacts
  Future<void> getAllContacts() async {
    await syncContactsFromRemote();
  }

  /// Insert or update a contact (and its image) remotely, then locally.
  Future<int> insertContact(ContactEntity contact, File? imageFile) async {
    final user = _auth.getCurrentUser();
    if (user == null) throw Exception('User not signed in');
    final uid = user.uid;

    // Assign a numeric ID if new
    final int contactId = contact.id > 0
        ? contact.id
        : DateTime.now().millisecondsSinceEpoch;
    contact.id = contactId;

    // 1) Upload image if provided
    String imageUrl = contact.image;
    if (imageFile != null) {
      imageUrl = await _storageService.uploadContactImage(
        imageFile: imageFile,
        userId:    uid,
        contactId: contactId.toString(),
      );
    }

    // 2) Write Firestore document
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .doc(contactId.toString())
        .set({
      'name':        contact.name,
      'mobile':      contact.mobile,
      'email':       contact.email,
      'address':     contact.address,
      'company':     contact.company,
      'designation': contact.designation,
      'website':     contact.website,
      'imageUrl':    imageUrl,
      'favorite':    contact.favorite,
    });

    // 3) Cache locally
    final cached = contact..image = imageUrl;
    await _dbHelper.insertContact(cached);

    // 4) Refresh stream
    await getAllContacts();
    return contactId;
  }

  Future<void> deleteContact(int id) async {
    final user = _auth.getCurrentUser();
    if (user == null) return;
    final uid = user.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .doc(id.toString())
        .delete();

    await _dbHelper.deleteContact(id);
    await getAllContacts();
  }

  Future<void> toggleFavorite(int id, bool currentFavorite) async {
    final user = _auth.getCurrentUser();
    if (user == null) return;
    final uid = user.uid;
    final newFav = !currentFavorite;

    // Remote
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .doc(id.toString())
        .update({'favorite': newFav});

    // Local
    await _dbHelper.updateFavorite(id, newFav ? 1 : 0);
    await getAllContacts();
  }

  Future<ContactEntity> getContactById(int id) async {
    final user = _auth.getCurrentUser();
    if (user == null) throw Exception('User not signed in');
    final uid = user.uid;

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .doc(id.toString())
        .get();

    final data = doc.data()!;
    final contact = ContactEntity(
      id:          id,
      name:        data['name'] ?? '',
      mobile:      data['mobile'] ?? '',
      email:       data['email'] ?? '',
      address:     data['address'] ?? '',
      company:     data['company'] ?? '',
      designation: data['designation'] ?? '',
      website:     data['website'] ?? '',
      image:       data['imageUrl'] ?? '',
      favorite:    data['favorite'] == true,
    );

    // Cache locally
    await _dbHelper.insertContact(contact);
    return contact;
  }

  Future<List<ContactEntity>> getFavoriteContacts() async {
    final user = _auth.getCurrentUser();
    if (user == null) return [];
    final uid = user.uid;

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .where('favorite', isEqualTo: true)
        .get();

    final favs = snapshot.docs.map((doc) {
      final d = doc.data();
      return ContactEntity(
        id:          int.tryParse(doc.id) ?? 0,
        name:        d['name'] ?? '',
        mobile:      d['mobile'] ?? '',
        email:       d['email'] ?? '',
        address:     d['address'] ?? '',
        company:     d['company'] ?? '',
        designation: d['designation'] ?? '',
        website:     d['website'] ?? '',
        image:       d['imageUrl'] ?? '',
        favorite:    true,
      );
    }).toList();

    _contactStreamController.add(favs);
    return favs;
  }

  void dispose() {
    _contactStreamController.close();
  }
}
