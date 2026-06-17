// pages/admin/product_management_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../product/add_product_page.dart';
import '../product/edit_product_page.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final ProductService _productService = ProductService();

  void confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: Text("Apakah Anda yakin ingin menghapus '${product.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (product.id != null) {
                  await _productService.deleteProduct(product.id!);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${product.name} berhasil dihapus")),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menghapus: $e")),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text(
          "Kelola Produk",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada produk.", style: TextStyle(color: Colors.grey)),
            );
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              bool isNetworkImage = product.image.startsWith('http');
              bool isAssetImage = product.image.startsWith('assets/');

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: isNetworkImage
                          ? Image.network(product.image, fit: BoxFit.cover)
                          : isAssetImage
                          ? Image.asset(product.image, fit: BoxFit.cover)
                          : Image.memory(base64Decode(product.image), fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Rp ${product.price} | Stok: ${product.stock}",
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.isActive ? "Status: AKTIF" : "Status: NON-AKTIF",
                          style: TextStyle(
                            color: product.isActive ? Colors.green.shade700 : Colors.red.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductPage(product: product),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => confirmDelete(product),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}