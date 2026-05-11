import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../product/add_product_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColor.background,

      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        child: const Icon(Icons.add),
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductPage(),
            ),
          );

        },
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // SEARCH
            TextField(
              decoration: InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CARD
            Row(
              children: [

                Expanded(
                  child: card(
                    "Produk",
                    "120",
                    Icons.shopping_bag,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: card(
                    "Order",
                    "80",
                    Icons.receipt_long,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 15),

            // BANNER
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "Promo Hari Ini",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [

                Text(
                  "Produk",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text("Lihat Semua"),

              ],
            ),

            const SizedBox(height: 20),

            // GRID PRODUCT
            GridView.builder(

              itemCount: 4,

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount: 2,

                crossAxisSpacing: 15,
                mainAxisSpacing: 15,

                childAspectRatio: 0.72,

              ),

              itemBuilder: (context, index) {

                return Container(

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            const Text(
                              "Beras Premium",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Stok: 100",
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Rp 75.000",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
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

              },
            )

          ],
        ),
      ),
    );
  }

  Widget card(
      String title,
      String total,
      IconData icon,
      ) {

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: AppColor.primary,
          ),

          const SizedBox(height: 10),

          Text(
            total,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(title),

        ],
      ),
    );
  }
}