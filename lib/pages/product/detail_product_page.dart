import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/product_model.dart';

class DetailProductPage extends StatelessWidget {

  final ProductModel product;

  const DetailProductPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColor.background,

      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: Text(
          product.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // IMAGE
            Image.asset(
              product.image,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    product.name,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    product.price,

                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Stok : ${product.stock}",

                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Deskripsi Produk",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Produk sembako berkualitas dan cocok untuk kebutuhan sehari-hari.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(

                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(

                      onPressed: () {},

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColor.primary,
                      ),

                      child: const Text(
                        "Tambah ke Keranjang",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )

                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}