// widgets/product_card.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import untuk update status realtime

import '../config/app_color.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final bool isAdmin; // Ditambahkan untuk membedakan fitur Admin & Kasir

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isAdmin = false, // Default false agar tidak merusak halaman lain
  });

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = product.image.startsWith('http');
    bool isAssetImage = product.image.startsWith('assets/');

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        // REVISI: Jika produk nonaktif, buat agak pudar (khusus di mata Admin)
        opacity: product.isActive ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BAGIAN GAMBAR
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: isNetworkImage
                            ? Image.network(product.image, fit: BoxFit.cover)
                            : isAssetImage
                            ? Image.asset(product.image, fit: BoxFit.cover)
                            : Image.memory(
                          base64Decode(product.image),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            );
                          },
                        ),
                      ),

                      // REVISI: Badge Penanda "Non-Aktif" (Hanya Muncul di Layar Admin)
                      if (!product.isActive && isAdmin)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Non-Aktif",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      // REVISI: TOMBOL TITIK 3 OTOMATIS (Hanya Muncul Jika User = Admin)
                      if (isAdmin)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.black87, size: 20),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (value) async {
                                if (value == 'toggle_status') {
                                  try {
                                    // Tembak update status langsung ke dokumen Firebase Firestore
                                    await FirebaseFirestore.instance
                                        .collection('products')
                                        .doc(product.id)
                                        .update({'isActive': !product.isActive});

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            product.isActive
                                                ? "${product.name} berhasil dinonaktifkan!"
                                                : "${product.name} berhasil diaktifkan kembali!"
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint("Gagal mengubah status: $e");
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'toggle_status',
                                  child: Row(
                                    children: [
                                      Icon(
                                        product.isActive ? Icons.visibility_off : Icons.visibility,
                                        color: product.isActive ? Colors.red : Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        product.isActive ? "Nonaktifkan" : "Aktifkan",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // DETAIL TEKS
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Rp ${product.price}",
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        "Stok: ${product.stock}",
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}