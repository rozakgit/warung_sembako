import 'package:flutter/material.dart';
import '../../services/transaction_service.dart';
import 'receipt_page.dart';
import '../../config/app_color.dart';
import '../../services/cart_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: const Text(
          "Keranjang Belanja",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // AnimatedBuilder berfungsi mendengarkan perubahan data di CartService
      body: AnimatedBuilder(
        animation: cartService,
        builder: (context, child) {
          if (cartService.items.isEmpty) {
            return const Center(
              child: Text(
                "Keranjang masih kosong.\nSilakan pilih produk terlebih dahulu.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              // LIST PRODUK DI KERANJANG
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final item = cartService.items[index];
                    final isNetworkImage = item.product.image.startsWith('http');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: isNetworkImage
                                    ? Image.network(item.product.image, fit: BoxFit.cover)
                                    : Image.asset(item.product.image, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp ${item.product.price}",
                                    style: const TextStyle(color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                            // TOMBOL MINUS & PLUS
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      cartService.updateQuantity(index, item.quantity - 1);
                                    } else {
                                      cartService.removeFromCart(index);
                                    }
                                  },
                                ),
                                Text(
                                  "${item.quantity}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppColor.primary),
                                  onPressed: () {
                                    if (item.quantity < item.product.stock) {
                                      cartService.updateQuantity(index, item.quantity + 1);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Stok tidak mencukupi!")),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // BOX TOTAL & TOMBOL CHECKOUT
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Pembayaran", style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text(
                          "Rp ${cartService.totalPrice}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ... [kode sebelumnya] ...
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          // Tampilkan Loading Dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            // 1. DUPLIKAT DATA KERANJANG SEBELUM DIHAPUS (PENTING UNTUK PRINT)
                            final copiedItems = List.from(cartService.items);
                            int finalTotal = cartService.totalPrice;

                            // 2. Proses Checkout via TransactionService
                            String txId = await TransactionService().checkout(
                              cartService.items,
                              cartService.totalPrice,
                            );

                            // 3. Kosongkan Keranjang setelah sukses di Firebase
                            cartService.clearCart();

                            // 4. Tutup Loading Dialog
                            if (!context.mounted) return;
                            Navigator.pop(context);

                            // 5. Pindah ke Halaman Receipt dengan membawa data copiedItems
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReceiptPage(
                                  transactionId: txId,
                                  total: finalTotal,
                                  items: copiedItems, // Kirim ke halaman struk
                                ),
                              ),
                            );

                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context); // Tutup Loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Text(
                          "Checkout Sekarang",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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