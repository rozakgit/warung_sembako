import 'package:flutter/material.dart';

import '../config/app_color.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {

  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          ClipRRect(

            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),

            child: Image.asset(

              product.image,

              height: 120,
              width: double.infinity,

              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  product.name,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Stok : ${product.stock}",

                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  product.price,

                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: () {},

                    style: ElevatedButton.styleFrom(

                      backgroundColor: AppColor.primary,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Detail",

                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )

              ],
            ),
          )

        ],
      ),
    );
  }
}