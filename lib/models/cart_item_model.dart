import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  // Otomatis menghitung subtotal per item
  int get subtotal => product.price * quantity;
}