// pages/product/detail_product_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';

class DetailProductPage extends StatefulWidget {
  final ProductModel product;
  final bool isAdmin; // REVISI: Tambahan parameter untuk mendeteksi role Admin

  const DetailProductPage({
    super.key,
    required this.product,
    this.isAdmin = false, // Default false
  });

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  int quantity = 1;
  int currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> imageSlider =
    (widget.product.images != null && widget.product.images!.isNotEmpty)
        ? widget.product.images!
        : [widget.product.image];

    bool isActive = widget.product.isActive;

    // REVISI: Logika Kunci Keamanan Ganda (Aktif & Role)
    bool canAddToCart = isActive && !widget.isAdmin;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 350,
                      child: PageView.builder(
                        itemCount: imageSlider.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentImage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          bool isNetworkImage = imageSlider[index].startsWith('http');
                          bool isAssetImage = imageSlider[index].startsWith('assets/');

                          return SizedBox(
                            width: double.infinity,
                            child: isNetworkImage
                                ? Image.network(imageSlider[index], fit: BoxFit.cover)
                                : isAssetImage
                                ? Image.asset(imageSlider[index], fit: BoxFit.cover)
                                : Image.memory(base64Decode(imageSlider[index]), fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    imageSlider.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentImage == index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentImage == index ? AppColor.primary : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (!isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                              child: const Text("NONAKTIF", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text("Rp ${widget.product.price}", style: const TextStyle(color: Colors.orange, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Stok tersedia : ${widget.product.stock}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 30),

                      const Text("Deskripsi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text(
                        "Produk sembako berkualitas tinggi dan cocok untuk kebutuhan sehari-hari.",
                        style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                      ),
                      const SizedBox(height: 35),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Jumlah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Container(
                            decoration: BoxDecoration(
                              color: canAddToCart ? AppColor.background : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  // REVISI: Tombol Kunci Ganda
                                  onPressed: canAddToCart ? () {
                                    if (quantity > 1) setState(() => quantity--);
                                  } : null,
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(quantity.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: canAddToCart ? Colors.black : Colors.grey)),
                                IconButton(
                                  // REVISI: Tombol Kunci Ganda
                                  onPressed: canAddToCart ? () {
                                    if (quantity < widget.product.stock) {
                                      setState(() => quantity++);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stok tidak mencukupi!")));
                                    }
                                  } : null,
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)]),
                  child: const Icon(Icons.favorite_border, color: Colors.red),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      // REVISI: Eksekusi dikunci menggunakan canAddToCart
                      onPressed: canAddToCart ? () {
                        CartService().addToCart(widget.product, quantity);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${widget.product.name} (x$quantity) masuk keranjang")));
                        Navigator.pop(context);
                      } : null,
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: Text(
                        // REVISI: Penamaan Teks Tombol Cerdas
                        widget.isAdmin
                            ? "Khusus Pegawai Kasir"
                            : (isActive ? "Tambah ke Keranjang" : "Produk Dinonaktifkan"),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAddToCart ? AppColor.primary : Colors.grey.shade500,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}