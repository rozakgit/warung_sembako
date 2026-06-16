// pages/product/edit_product_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class EditProductPage extends StatefulWidget {
  final ProductModel product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameC;
  late TextEditingController priceC;
  late TextEditingController stockC;
  late TextEditingController imageC;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Mengisi form dengan data produk yang sudah ada
    nameC = TextEditingController(text: widget.product.name);
    priceC = TextEditingController(text: widget.product.price.toString());
    stockC = TextEditingController(text: widget.product.stock.toString());
    imageC = TextEditingController(text: widget.product.image);
  }

  void updateProduct() async {
    if (nameC.text.isEmpty || priceC.text.isEmpty || stockC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, Harga, dan Stok tidak boleh kosong")),
      );
      return;
    }

    try {
      setState(() => loading = true);

      int price = int.parse(priceC.text.replaceAll(RegExp(r'[^0-9]'), ''));
      int stock = int.parse(stockC.text.replaceAll(RegExp(r'[^0-9]'), ''));
      String image = imageC.text.isNotEmpty ? imageC.text : 'assets/images/b1.jpg';

      // Membentuk objek ProductModel dengan ID yang sama
      ProductModel updatedProduct = ProductModel(
        id: widget.product.id,
        name: nameC.text,
        price: price,
        stock: stock,
        image: image,
        images: widget.product.images, // Pertahankan images lama
        isActive: widget.product.isActive,
      );

      // Kirim perintah update ke Service
      await ProductService().updateProduct(updatedProduct);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil diupdate!")),
      );

      Navigator.pop(context); // Kembali ke list product management
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget customField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        title: const Text(
          "Edit Produk",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Update Data Produk", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                customField(controller: nameC, hint: "Nama Produk", icon: Icons.shopping_bag),
                const SizedBox(height: 20),
                customField(controller: priceC, hint: "Harga", icon: Icons.attach_money, keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                customField(controller: stockC, hint: "Stok", icon: Icons.inventory, keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                customField(controller: imageC, hint: "Link URL Gambar", icon: Icons.image),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: loading ? null : updateProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Update Produk", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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