// services/transaction_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> checkout(List<CartItemModel> cartItems, int total) async {
    try {
      // Dapatkan UID Kasir yang sedang login
      String cashierId = _auth.currentUser?.uid ?? 'unknown';
      String dateNow = DateTime.now().toIso8601String(); // Waktu saat ini

      // Gunakan batch untuk memastikan semua data tersimpan secara bersamaan (atomic)
      WriteBatch batch = _firestore.batch();

      // 1. Siapkan data referensi dokumen transaksi baru
      DocumentReference transactionRef = _firestore.collection('transactions').doc();

      // Format data item belanjaan
      List<Map<String, dynamic>> itemsDetail = cartItems.map((item) {
        return {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'qty': item.quantity,
          'subtotal': item.subtotal,
        };
      }).toList();

      // Tambahkan instruksi untuk menyimpan transaksi ke dalam batch
      batch.set(transactionRef, {
        'cashierId': cashierId,
        'total': total,
        'date': dateNow,
        'items': itemsDetail,
      });

      // 2. Tambahkan instruksi untuk mengurangi stok produk ke dalam batch
      for (var item in cartItems) {
        if (item.product.id != null) {
          DocumentReference productRef = _firestore.collection('products').doc(item.product.id);
          batch.update(productRef, {
            'stock': FieldValue.increment(-item.quantity) // Kurangi stok
          });
        }
      }

      // Eksekusi semua instruksi batch sekaligus ke server Firebase
      await batch.commit();

      return transactionRef.id; // Kembalikan ID transaksi untuk di struk
    } catch (e) {
      throw Exception('Gagal melakukan checkout: $e');
    }
  }
}