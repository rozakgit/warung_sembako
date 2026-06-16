import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService extends ChangeNotifier {
  // Membuat Singleton agar data keranjang tetap sama di seluruh halaman aplikasi
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItemModel> items = [];

  void addToCart(ProductModel product, int quantity) {
    // Cek apakah produk sudah ada di keranjang
    int index = items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      items[index].quantity += quantity; // Tambah jumlah jika sudah ada
    } else {
      items.add(CartItemModel(product: product, quantity: quantity)); // Masukkan produk baru
    }
    notifyListeners(); // Perbarui UI secara otomatis
  }

  void removeFromCart(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    items.clear();
    notifyListeners();
  }

  int get totalPrice {
    int total = 0;
    for (var item in items) {
      total += item.subtotal;
    }
    return total;
  }
}