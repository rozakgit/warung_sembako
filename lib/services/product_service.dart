// services/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. CREATE: Tambah produk baru
  Future<void> addProduct(ProductModel product) async {
    try {
      // REVISI: Mengubah toMap() menjadi toFirestore()
      await _firestore.collection('products').add(product.toFirestore());
    } catch (e) {
      throw Exception('Gagal menambah produk: $e');
    }
  }

  // 2. READ: Mengambil daftar semua produk secara realtime
  Stream<List<ProductModel>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // REVISI: Mengubah dari fromMap menjadi fromFirestore
        // Karena fungsi fromFirestore langsung menerima objek 'doc' (DocumentSnapshot), kodenya jadi jauh lebih ringkas!
        return ProductModel.fromFirestore(doc);
      }).toList();
    });
  }

  // 3. UPDATE: Mengubah data produk yang sudah ada
  Future<void> updateProduct(ProductModel product) async {
    try {
      if (product.id != null) {
        // REVISI: Mengubah toMap() menjadi toFirestore()
        await _firestore.collection('products').doc(product.id).update(product.toFirestore());
      }
    } catch (e) {
      throw Exception('Gagal mengupdate produk: $e');
    }
  }

  // 4. DELETE: Menghapus produk
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }
}