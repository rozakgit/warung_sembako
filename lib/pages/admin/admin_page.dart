import 'package:flutter/material.dart';
import 'product_management_page.dart';
import '../../config/app_color.dart';
import '../profile/profile_page.dart';
import 'user_management_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,

      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Selamat Datang Admin 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [

                Expanded(
                  child: _menuCard(
                    context,
                    title: "Produk",
                    icon: Icons.shopping_bag,
                    color: Colors.orange,
                    onTap: () {
                      // Product Management
                    },
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _menuCard(
                    context,
                    title: "Pengguna",
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () {
                      // User Management
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                Expanded(
                  child: _menuCard(
                    context,
                    title: "Laporan Harian",
                    icon: Icons.bar_chart,
                    color: Colors.green,
                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                          const UserManagementPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _menuCard(
                    context,
                    title: "Laporan Bulanan",
                    icon: Icons.analytics,
                    color: Colors.purple,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Statistik Hari Ini",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.05,
                    ),
                    blurRadius: 10,
                  )
                ],
              ),

              child: Column(
                children: [

                  _statRow(
                    "Pendapatan",
                    "Rp 1.500.000",
                  ),

                  const Divider(),

                  _statRow(
                    "Transaksi",
                    "35",
                  ),

                  const Divider(),

                  _statRow(
                    "Produk Terjual",
                    "120",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
      BuildContext context, {

        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,

      }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        height: 130,

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(20),

          boxShadow: [

            BoxShadow(
              color: Colors.black.withOpacity(
                0.05,
              ),
              blurRadius: 10,
            ),
          ],
        ),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 40,
              color: color,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [

          Text(title),

          Text(
            value,
            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}