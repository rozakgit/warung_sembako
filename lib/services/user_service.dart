import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Mengambil daftar semua user secara realtime (Stream)
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // 2. Mengupdate role user (misal: dari cashier menjadi admin)
  Future<void> updateRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
    } catch (e) {
      throw Exception('Gagal mengupdate role: $e');
    }
  }

  // 3. Menghapus data user dari Firestore
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();

      // Catatan: Ini hanya menghapus data user di Firestore.
      // Untuk menghapus akses login seutuhnya dari Firebase Auth via Client (Admin),
      // idealnya membutuhkan Firebase Cloud Functions atau Firebase Admin SDK.
      // Namun menghapus dokumennya saja sudah cukup untuk membatasi akses role-nya.
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }
}