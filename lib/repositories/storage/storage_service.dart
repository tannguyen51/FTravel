import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service để upload files lên Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload avatar lên Firebase Storage
  /// Returns download URL của file đã upload
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Tạo reference đến file trong Storage
      final storageRef = _storage.ref();
      final avatarRef = storageRef.child('avatars/${user.uid}/avatar.jpg');

      // Upload file
      final uploadTask = await avatarRef.putFile(imageFile);

      // Lấy download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  /// Xóa avatar cũ (optional)
  Future<void> deleteAvatar() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final avatarRef = _storage.ref().child('avatars/${user.uid}/avatar.jpg');
      await avatarRef.delete();
    } catch (e) {
      print('Error deleting avatar: $e');
    }
  }
}
