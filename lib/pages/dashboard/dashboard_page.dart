// pages/dashboard/dashboard_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/product_model.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/product_card.dart';
import '../admin/daily_report_page.dart';
import '../product/add_product_page.dart';
import '../product/detail_product_page.dart';
import '../profile/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;
  final TextEditingController searchC = TextEditingController();

  // Variabel untuk menyimpan role dan status loading
  String userRole = 'cashier';
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Ambil role saat halaman pertama kali dimuat
  }

  // Fungsi mengambil role dari Firestore secara realtime/async
  void _checkUserRole() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            userRole = doc.data()?['role'] ?? 'cashier';
          });
        }
      }
    } catch (e) {
      debugPrint("Error mengambil role: $e");
    } finally {
      setState(() {
        isLoadingRole = false;
      });
    }
  }

  final List<ProductModel> products = [
    ProductModel(
      name: "Beras Premium",
      price: "Rp 75.000",
      stock: "100",
      image: "assets/images/b1.jpg",
      images: [
        "assets/images/b1.jpg",
        "assets/images/b2.jpg",
        "assets/images/b3.jpg",
      ],
    ),
    ProductModel(
      name: "Minyak Goreng",
      price: "Rp 20.000",
      stock: "50",
      image: "assets/images/m1.jpg",
      images: [
        "assets/images/m1.jpg",
        "assets/images/m2.jpg",
        "assets/images/m3.jpg",
      ],
    ),
    ProductModel(
      name: "Telur Ayam",
      price: "Rp 30.000",
      stock: "80",
      image: "assets/images/t1.jpg",
      images: [
        "assets/images/t1.jpg",
        "assets/images/t2.jpg",
        "assets/images/t3.jpg",
      ],
    ),
    ProductModel(
      name: "Gula Pasir",
      price: "Rp 18.000",
      stock: "40",
      image: "assets/images/g1.jpg",
      images: [
        "assets/images/g1.jpg",
        "assets/images/g2.jpg",
        "assets/images/g3.jpg",
      ],
    ),
    ProductModel(
      name: "Mie Instan",
      price: "Rp 5.000",
      stock: "200",
      image: "assets/images/mi1.jpg",
      images: [
        "assets/images/mi1.jpg",
        "assets/images/mi2.jpg",
        "assets/images/mi3.jpg",
      ],
    ),
    ProductModel(
      name: "Susu Kaleng",
      price: "Rp 12.000",
      stock: "60",
      image: "assets/images/s1.jpg",
      images: [
        "assets/images/s1.jpg",
        "assets/images/s2.jpg",
        "assets/images/s3.jpg",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Menampilkan loading indikator tipis di tengah layar saat memvalidasi role
    if (isLoadingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        title: const Text(
          "Warung Sembako",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // LOGIKA ROLE 1: FloatingActionButton hanya muncul jika role == 'admin'
      floatingActionButton: userRole == 'admin'
          ? FloatingActionButton(
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
      )
          : null, // Jika kasir, tombol + hilang otomatis

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================
              // SEARCH
              // ======================
              TextField(
                controller: searchC,
                decoration: InputDecoration(
                  hintText: "Cari produk...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 25),

              // ======================
              // STATISTIC
              // ======================
              Row(
                children: const [
                  Expanded(
                    child: DashboardCard(
                      title: "Produk",
                      total: "120",
                      icon: Icons.shopping_bag,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: DashboardCard(
                      title: "Order",
                      total: "80",
                      icon: Icons.receipt_long,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: const [
                  Expanded(
                    child: DashboardCard(
                      title: "Stok",
                      total: "500",
                      icon: Icons.inventory,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: DashboardCard(
                      title: "Pendapatan",
                      total: "2 JT",
                      icon: Icons.attach_money,
                    ),
                  ),
                ],
              ),

              // LOGIKA ROLE 2: Blok Laporan Harian hanya dirender jika role == 'admin'
              if (userRole == 'admin') ...[
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DailyReportPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.bar_chart,
                            color: AppColor.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Laporan Harian",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Lihat pendapatan dan transaksi hari ini",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 25),

              // ======================
              // BANNER
              // ======================
              Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/b1.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ======================
              // TITLE
              // ======================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Produk",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Semua produk"),
                        ),
                      );
                    },
                    child: const Text("Lihat Semua"),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // ======================
              // PRODUCT GRID
              // ======================
              GridView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailProductPage(
                            product: products[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ======================
      // BOTTOM NAVBAR
      // ======================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              currentIndex = index;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Home")),
            );
          } else if (index == 1) {
            setState(() {
              currentIndex = index;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cart")),
            );
          } else if (index == 2) {
            setState(() {
              currentIndex = index;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilePage(),
              ),
            ).then((_) {
              setState(() {
                currentIndex = 0;
              });
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}