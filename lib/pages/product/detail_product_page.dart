// pages/product/detail_product_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart'; // Import service keranjang

class DetailProductPage extends StatefulWidget {
  final ProductModel product;

  const DetailProductPage({
    super.key,
    required this.product,
  });

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  int quantity = 1;
  int currentImage = 0;

  @override
  Widget build(BuildContext context) {
    // LOGIKA PENGECEKAN GAMBAR
    final List<String> imageSlider =
    (widget.product.images != null && widget.product.images!.isNotEmpty)
        ? widget.product.images!
        : [widget.product.image];

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // IMAGE SLIDER
                // =========================
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

                          return isNetworkImage
                              ? Image.network(
                            imageSlider[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            imageSlider[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    // BACK BUTTON
                    Positioned(
                      top: 50,
                      left: 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // =========================
                // INDICATOR
                // =========================
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    imageSlider.length,
                        (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        width: currentImage == index ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentImage == index
                              ? AppColor.primary
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      );
                    },
                  ),
                ),

                // =========================
                // CONTENT
                // =========================
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PRODUCT NAME
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // PRICE
                      Text(
                        "Rp ${widget.product.price}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // STOCK
                      Text(
                        "Stok tersedia : ${widget.product.stock}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // DESCRIPTION
                      const Text(
                        "Deskripsi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Produk sembako berkualitas tinggi dan cocok untuk kebutuhan sehari-hari.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 35),

                      // QUANTITY
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Jumlah",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.background,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (quantity > 1) {
                                      setState(() {
                                        quantity--;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (quantity < widget.product.stock) {
                                      setState(() {
                                        quantity++;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Stok tidak mencukupi!")),
                                      );
                                    }
                                  },
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

          // =========================
          // BOTTOM BUTTON
          // =========================
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      // LOGIKA TAMBAH KE KERANJANG DISINI
                      onPressed: () {
                        // 1. Tambahkan ke memori Cart Service
                        CartService().addToCart(widget.product, quantity);

                        // 2. Tampilkan notifikasi kecil di bawah
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${widget.product.name} (x$quantity) masuk keranjang",
                            ),
                          ),
                        );

                        // 3. Langsung kembali ke halaman utama
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Tambah ke Keranjang",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
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