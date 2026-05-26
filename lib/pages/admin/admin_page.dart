import 'package:flutter/material.dart';

import '../../config/app_color.dart';

import '../report/daily_report_page.dart';

class AdminPage extends StatelessWidget {

  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColor.background,

      appBar: AppBar(

        backgroundColor: AppColor.primary,

        title: const Text(

          "Admin Dashboard",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: GridView.count(

            crossAxisCount: 2,

            crossAxisSpacing: 15,
            mainAxisSpacing: 15,

            children: [

              // PRODUK
              buildMenu(

                context,

                icon: Icons.inventory,

                title: "Kelola Produk",

                onTap: () {},
              ),

              // TRANSAKSI
              buildMenu(

                context,

                icon: Icons.receipt_long,

                title: "Transaksi",

                onTap: () {},
              ),

              // LAPORAN
              buildMenu(

                context,

                icon: Icons.bar_chart,

                title: "Laporan",

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const DailyReportPage(),
                    ),
                  );
                },
              ),

              // PELANGGAN
              buildMenu(

                context,

                icon: Icons.people,

                title: "Pelanggan",

                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenu(

      BuildContext context, {

        required IconData icon,
        required String title,
        required VoidCallback onTap,

      }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(24),

          boxShadow: [

            BoxShadow(

              color:
              Colors.black.withOpacity(
                0.05,
              ),

              blurRadius: 10,

              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color:
                AppColor.primary.withOpacity(
                  0.1,
                ),

                borderRadius:
                BorderRadius.circular(18),
              ),

              child: Icon(

                icon,

                color: AppColor.primary,

                size: 35,
              ),
            ),

            const SizedBox(height: 15),

            Text(

              title,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}