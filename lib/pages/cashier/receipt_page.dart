// pages/cashier/receipt_page.dart

import 'package:flutter/material.dart';
import '../../config/app_color.dart';
import '../dashboard/dashboard_page.dart';

class ReceiptPage extends StatelessWidget {
  final String transactionId;
  final int total;
  final List<dynamic> items;
  final int uangTunai; // WAJIB ADA: Menangkap uang dari pelanggan
  final int kembalian; // WAJIB ADA: Menangkap hasil kembalian

  const ReceiptPage({
    super.key,
    required this.transactionId,
    required this.total,
    required this.items,
    required this.uangTunai,
    required this.kembalian,
  });

  // Fungsi Format Rupiah agar struk terlihat rapi
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
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    final String currentTime = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text("Struk Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "WARUNG SEMBAKO PRO",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Center(
                          child: Text(
                            "Jl. Merdeka No. 45, Kota Tangerang\nTelp: 0812-3456-7890",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const DashedDivider(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tgl : $currentDate $currentTime", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            const Text("Kasir : 01/Admin", style: TextStyle(fontSize: 12, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("No  : $transactionId", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 10),
                        const DashedDivider(),
                        const SizedBox(height: 10),

                        ...items.map((item) {
                          final name = item.product.name;
                          final price = item.product.price;
                          final qty = item.quantity;
                          final subtotal = price * qty;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toString().toUpperCase(),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("$qty  x  Rp ${formatCurrency(price)}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                    Text("Rp ${formatCurrency(subtotal)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 5),
                        const DashedDivider(),
                        const SizedBox(height: 10),

                        // ==========================================
                        // REVISI: TOTAL & PEMBAYARAN REALTIME
                        // ==========================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("TOTAL BELANJA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                            Text("Rp ${formatCurrency(total)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("TUNAI", style: TextStyle(fontSize: 13, color: Colors.black87)),
                            Text("Rp ${formatCurrency(uangTunai)}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("KEMBALI", style: TextStyle(fontSize: 13, color: Colors.black87)),
                            Text("Rp ${formatCurrency(kembalian)}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                          ],
                        ),

                        const SizedBox(height: 15),
                        const DashedDivider(),
                        const SizedBox(height: 15),

                        const Center(
                          child: Text(
                            "*** TERIMA KASIH ***",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Center(
                          child: Text(
                            "Barang yang sudah dibeli\ntidak dapat ditukar/dikembalikan.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(30, (index) {
                                return Container(width: index % 3 == 0 ? 3 : (index % 2 == 0 ? 1 : 2), color: Colors.black);
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Center(child: Text(transactionId.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 2))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Container(
                    height: 55, width: 55,
                    decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menghubungkan ke Printer Bluetooth...")));
                      },
                      icon: const Icon(Icons.print, color: AppColor.primary),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardPage()), (route) => false);
                        },
                        child: const Text("Selesai & Tutup", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashHeight = 1.5;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(width: dashWidth, height: dashHeight, child: DecoratedBox(decoration: BoxDecoration(color: Colors.black87)));
          }),
        );
      },
    );
  }
}