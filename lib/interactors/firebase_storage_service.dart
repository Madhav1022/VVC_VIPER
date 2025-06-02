import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads the visiting-card image under users/{uid}/contacts/{contactId}/
  /// and returns its download URL.
  Future<String> uploadContactImage({
    required File imageFile,
    required String userId,
    required String contactId,
  }) async {
    final fileName = imageFile.path.split('/').last;
    final ref = _storage
        .ref()
        .child('users/$userId/contacts/$contactId/$fileName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}
