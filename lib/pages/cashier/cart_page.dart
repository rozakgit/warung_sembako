// pages/cashier/cart_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'success_checkout_page.dart';
import '../../services/transaction_service.dart';
import '../../config/app_color.dart';
import '../../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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

  void _showPaymentDialog(BuildContext context, int totalPembayaran, List<dynamic> copiedItems, CartService cartService) {
    final TextEditingController cashC = TextEditingController();
    int cashReceived = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) { // Menggunakan nama variabel dialogContext agar tidak bentrok
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int kembalian = cashReceived - totalPembayaran;
            bool isCashEnough = cashReceived >= totalPembayaran;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.payments_outlined, color: AppColor.primary, size: 28),
                  SizedBox(width: 10),
                  Text("Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        const Text("Total Belanja", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("Rp ${formatCurrency(totalPembayaran)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.orange)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Uang Tunai Diterima:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: cashC,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: "Rp ",
                      prefixStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      hintText: "0",
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        cashReceived = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kembalian:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        kembalian < 0 ? "- Rp ${formatCurrency(kembalian.abs())}" : "Rp ${formatCurrency(kembalian)}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kembalian < 0 ? Colors.red : Colors.green
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: isCashEnough ? () {
                    Navigator.pop(dialogContext); // Tutup dialog input uang
                    _processCheckout(context, totalPembayaran, copiedItems, cartService, cashReceived);
                  } : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                  ),
                  child: const Text("PROSES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // LOGIKA PROSES FIREBASE ANTI NYANGKUT
  // =========================================================
  void _processCheckout(BuildContext context, int finalTotal, List<dynamic> copiedItems, CartService cartService, int cashReceived) async {
    // REVISI KRUSIAL: Ambil navigasi di awal sebelum proses async berjalan!
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Validasi Stok
      for (var item in cartService.items) {
        if (item.product.id != null) {
          var doc = await FirebaseFirestore.instance.collection('products').doc(item.product.id).get();
          if (!doc.exists) throw Exception("Produk '${item.product.name}' sudah dihapus dari sistem.");

          bool isCurrentlyActive = doc.data()?['isActive'] ?? true;
          if (!isCurrentlyActive) throw Exception("Gagal! Produk '${item.product.name}' dinonaktifkan Admin.");

          int currentStock = doc.data()?['stock'] ?? 0;
          if (currentStock < item.quantity) throw Exception("Stok '${item.product.name}' tidak mencukupi.");
        }
      }

      // 2. Eksekusi Pembayaran
      String txId = await TransactionService().checkout(cartService.items, cartService.totalPrice);
      cartService.clearCart();

      // REVISI: Pastikan selalu menutup loading tanpa terhalang if(!context.mounted)
      navigator.pop();

      // 3. Pindah Halaman
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => SuccessCheckoutPage(
            transactionId: txId,
            total: finalTotal,
            items: copiedItems,
            uangTunai: cashReceived,
            kembalian: cashReceived - finalTotal,
          ),
        ),
      );

    } catch (e) {
      // REVISI: Jika terjadi error, loading tetap ditutup paksa!
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red.shade700, duration: const Duration(seconds: 4)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text("Keranjang Belanja", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: cartService,
        builder: (context, child) {
          if (cartService.items.isEmpty) {
            return const Center(
              child: Text("Keranjang masih kosong.\nSilakan pilih produk terlebih dahulu.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final item = cartService.items[index];
                    bool isNetworkImage = item.product.image.startsWith('http');
                    bool isAssetImage = item.product.image.startsWith('assets/');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 70, height: 70,
                                child: isNetworkImage ? Image.network(item.product.image, fit: BoxFit.cover) : isAssetImage ? Image.asset(item.product.image, fit: BoxFit.cover) : Image.memory(base64Decode(item.product.image), fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text("Rp ${formatCurrency(item.product.price)}", style: const TextStyle(color: Colors.orange)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.grey), onPressed: () => item.quantity > 1 ? cartService.updateQuantity(index, item.quantity - 1) : cartService.removeFromCart(index)),
                                Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColor.primary), onPressed: () => item.quantity < item.product.stock ? cartService.updateQuantity(index, item.quantity + 1) : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stok tidak mencukupi!")))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Pembayaran", style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text("Rp ${formatCurrency(cartService.totalPrice)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final copiedItems = List.from(cartService.items);
                          _showPaymentDialog(context, cartService.totalPrice, copiedItems, cartService);
                        },
                        child: const Text("Checkout Sekarang", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}