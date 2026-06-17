// pages/dashboard/dashboard_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../cashier/cart_page.dart';
import '../../config/app_color.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/product_card.dart';
import '../admin/daily_report_page.dart';
import '../admin/product_management_page.dart';
import '../admin/user_management_page.dart';
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

  String userRole = 'cashier';
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

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

  String _formatShortRevenue(int nominal) {
    if (nominal >= 1000000) {
      return "${(nominal / 1000000).toStringAsFixed(1).replaceAll('.0', '')} JT";
    } else if (nominal >= 1000) {
      return "${(nominal / 1000).toStringAsFixed(0)} RB";
    }
    return nominal.toString();
  }

  @override
  Widget build(BuildContext context) {
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
          : null,
      body: SafeArea(
        child: StreamBuilder<List<ProductModel>>(
          stream: ProductService().getProducts(),
          builder: (context, productSnapshot) {
            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allProducts = productSnapshot.data ?? [];
            final totalJenisProduk = allProducts.length;
            final totalStokKumulatif = allProducts.fold<int>(0, (sum, p) => sum + p.stock);

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
              builder: (context, transactionSnapshot) {
                final transactionDocs = transactionSnapshot.data?.docs ?? [];
                final totalOrderSelesai = transactionDocs.length;
                int totalUangMasuk = 0;

                for (var doc in transactionDocs) {
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data != null) {
                    totalUangMasuk += (data['total'] ?? data['totalPrice'] ?? 0) as int;
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      Row(
                        children: [
                          Expanded(child: DashboardCard(title: "Produk", total: totalJenisProduk.toString(), icon: Icons.shopping_bag)),
                          const SizedBox(width: 15),
                          Expanded(child: DashboardCard(title: "Order", total: totalOrderSelesai.toString(), icon: Icons.receipt_long)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: DashboardCard(title: "Stok", total: totalStokKumulatif.toString(), icon: Icons.inventory)),
                          const SizedBox(width: 15),
                          Expanded(child: DashboardCard(title: "Pendapatan", total: _formatShortRevenue(totalUangMasuk), icon: Icons.attach_money)),
                        ],
                      ),

                      if (userRole == 'admin') ...[
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyReportPage()));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                            child: Row(
                              children: [
                                Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.bar_chart, color: AppColor.primary, size: 30)),
                                const SizedBox(width: 15),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Laporan Harian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text("Lihat pendapatan dan transaksi hari ini", style: TextStyle(color: Colors.grey))])),
                                const Icon(Icons.arrow_forward_ios, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementPage()));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                            child: Row(
                              children: [
                                Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.edit_note, color: AppColor.primary, size: 30)),
                                const SizedBox(width: 15),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Kelola Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text("Ubah harga, tambah stok, hapus produk", style: TextStyle(color: Colors.grey))])),
                                const Icon(Icons.arrow_forward_ios, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                            child: Row(
                              children: [
                                Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.people_alt, color: AppColor.primary, size: 30)),
                                const SizedBox(width: 15),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Kelola User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text("Atur hak akses kasir/admin dan hapus akun", style: TextStyle(color: Colors.grey))])),
                                const Icon(Icons.arrow_forward_ios, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 25),

                      Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), image: const DecorationImage(image: AssetImage("assets/images/b1.jpg"), fit: BoxFit.cover)),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Produk", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          TextButton(onPressed: () {}, child: const Text("Lihat Semua"))
                        ],
                      ),
                      const SizedBox(height: 20),

                      Builder(
                        builder: (context) {
                          var displayProducts = List<ProductModel>.from(allProducts);

                          if (userRole == 'cashier') {
                            displayProducts = displayProducts.where((p) => p.isActive == true).toList();
                          }

                          if (searchC.text.isNotEmpty) {
                            displayProducts = displayProducts.where((p) => p.name.toLowerCase().contains(searchC.text.toLowerCase())).toList();
                          }

                          if (displayProducts.isEmpty) {
                            return const Center(
                              child: Padding(padding: EdgeInsets.all(20.0), child: Text("Produk tidak ditemukan.", style: TextStyle(color: Colors.grey))),
                            );
                          }

                          return GridView.builder(
                            itemCount: displayProducts.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.58,
                            ),
                            itemBuilder: (context, index) {
                              return ProductCard(
                                product: displayProducts[index],
                                isAdmin: userRole == 'admin',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailProductPage(
                                        product: displayProducts[index],
                                        isAdmin: userRole == 'admin', // REVISI: Kirim data Role Admin ke halaman detail
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              currentIndex = index;
            });
          } else if (index == 1) {
            // =========================================================
            // REVISI: BLOKIR ADMIN UNTUK MASUK KE HALAMAN KERANJANG
            // =========================================================
            if (userRole == 'admin') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.gpp_bad, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Akses Ditolak: Transaksi hanya untuk Kasir!"),
                    ],
                  ),
                  backgroundColor: Colors.red.shade700,
                  duration: const Duration(seconds: 2),
                ),
              );
              return; // Menghentikan navigasi
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartPage(),
              ),
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