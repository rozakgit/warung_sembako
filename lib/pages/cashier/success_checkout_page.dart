// pages/cashier/success_checkout_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../dashboard/dashboard_page.dart';
import 'receipt_page.dart';

class SuccessCheckoutPage extends StatelessWidget {
  final String transactionId;
  final int total;
  final List<dynamic> items;
  final int uangTunai;   // REVISI: Parameter penangkap uang tunai
  final int kembalian;   // REVISI: Parameter penangkap kembalian

  const SuccessCheckoutPage({
    super.key,
    required this.transactionId,
    required this.total,
    required this.items,
    required this.uangTunai,
    required this.kembalian,
  });

  String formatCurrency(int amount) {
    String price = amount.toString();
    String result = '';
    int count = 0;
    for (int i = price.length - 1; i >= 0; i--) {
      count++;
      result = price[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 90,
                  ),
                ),
                const SizedBox(height: 25),

                const Text(
                  "Pembayaran Berhasil!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "ID Transaksi: ${transactionId.substring(0, 8).toUpperCase()}",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 25),

                // KARTU AUDIT RINCIAN KEMBALIAN KASIR (SESUAI REKOMENDASI)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Tagihan", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Uang Tunai", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(formatCurrency(uangTunai), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Uang Kembalian", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(formatCurrency(kembalian), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // TOMBOL CETAK STRUK
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceiptPage(
                            transactionId: transactionId,
                            total: total,
                            items: items,
                            uangTunai: uangTunai, // <--- PASTIKAN INI ADA
                            kembalian: kembalian, // <--- PASTIKAN INI ADA
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.receipt_long, color: AppColor.primary),
                    label: const Text(
                      "Lihat / Cetak Struk",
                      style: TextStyle(color: AppColor.primary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // TOMBOL KEMBALI KE HOME
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
                            (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text(
                      "Kembali ke Beranda",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}