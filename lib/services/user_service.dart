import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahan import
import 'package:firebase_core/firebase_core.dart'; // Tambahan import
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Realtime Stream Users
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update Role
  Future<void> updateRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
    } catch (e) {
      throw Exception('Gagal mengupdate role: $e');
    }
  }

  // Delete User
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }

  // LOGIKA BARU: Tambah User langsung oleh Admin tanpa Logout Sesi Admin
  Future<void> createUserByAdmin({
    required String name,
    required String username,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Buat koneksi aplikasi Firebase kedua sementara di memori
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      // Daftarkan akun baru ke Firebase Auth menggunakan instance aplikasi kedua
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      // Bentuk data model pengguna baru
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        username: username,
        phone: phone,
        email: email,
        role: role,
      );

      // Simpan data profil tambahan ke Firestore menggunakan aplikasi utama
      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      // Hapus secondary app dari memori setelah selesai
      await secondaryApp.delete();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}