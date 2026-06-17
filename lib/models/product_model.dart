// models/product_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String? id;
  String name;
  int price;
  int modal; // FIELD BARU: Harga Modal / Beli dari Agen
  int stock;
  String image;
  bool isActive;
  List<String>? images; // Menjaga kompatibilitas jika ada slider gambar

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.modal, // Wajib diisi saat membuat objek baru
    required this.stock,
    required this.image,
    required this.isActive,
    this.images,
  });

  // =======================================================
  // FUNGSI 1: MENGUBAH DATA DARI FIRESTORE MENJADI OBJEK DART
  // =======================================================
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: _parseToInt(data['price']),
      modal: _parseToInt(data['modal'] ?? data['costPrice']), // Fallback jika di database pakai nama costPrice
      stock: _parseToInt(data['stock']),
      image: data['image'] ?? 'https://via.placeholder.com/400x400.png?text=Tanpa+Foto',
      isActive: data['isActive'] ?? true,
      images: data['images'] != null ? List<String>.from(data['images']) : null,
    );
  }

  // =======================================================
  // FUNGSI 2: MENGUBAH OBJEK DART MENJADI MAP UNTUK DISIMPAN KE FIRESTORE
  // =======================================================
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'modal': modal, // Ikut tersimpan ke Firestore saat Admin tambah/edit barang
      'stock': stock,
      'image': image,
      'isActive': isActive,
      if (images != null) 'images': images,
    };
  }

  // Helper untuk memastikan data String/Double dari Firestore aman dikonversi ke Integer
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}