// pages/product/add_product_page.dart

import 'dart:io';
import 'dart:convert'; // Untuk fungsi base64
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_color.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final modalC = TextEditingController(); // REVISI: Tambah controller Harga Modal (Harga Beli)
  final stockC = TextEditingController();

  bool loading = false;
  bool isActive = true;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 400,    // Membatasi lebar gambar agar ukuran Base64 hemat
      imageQuality: 50,  // Kompres kualitas foto demi performa maksimal
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Pilih Sumber Foto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColor.primary, size: 30),
                title: const Text("Ambil dari Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue, size: 30),
                title: const Text("Pilih dari Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void saveProduct() async {
    // REVISI: Validasi pengecekan field modalC tidak boleh kosong
    if (nameC.text.isEmpty || priceC.text.isEmpty || modalC.text.isEmpty || stockC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, Harga Modal, Harga Jual, dan Stok tidak boleh kosong")),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      int price = int.parse(priceC.text.replaceAll(RegExp(r'[^0-9]'), ''));
      int modal = int.parse(modalC.text.replaceAll(RegExp(r'[^0-9]'), '')); // REVISI: Parsing nilai Harga Modal
      int stock = int.parse(stockC.text.replaceAll(RegExp(r'[^0-9]'), ''));

      String imageUrl = 'https://via.placeholder.com/400x400.png?text=Tanpa+Foto';

      // ==========================================
      // AKSI JITU: UBAH GAMBAR JADI BASE64 STRING
      // ==========================================
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        imageUrl = base64Encode(imageBytes); // Mengonversi foto menjadi teks
      }

      // REVISI: Masukkan data 'modal' ke dalam konstruktor ProductModel
      // Note: Pastikan field 'modal' sudah ditambahkan di file product_model.dart kamu ya!
      ProductModel newProduct = ProductModel(
        name: nameC.text,
        price: price,
        modal: modal, // Field Baru Harga Modal Agen
        stock: stock,
        image: imageUrl,
        isActive: isActive,
      );

      await ProductService().addProduct(newProduct);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil ditambahkan!")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
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
          "Tambah Produk",
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
                const Text("Data Produk", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColor.primary.withOpacity(0.5), width: 2, style: BorderStyle.solid),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 40, color: AppColor.primary),
                          SizedBox(height: 10),
                          Text("Pilih Foto", style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                customField(controller: nameC, hint: "Nama Produk", icon: Icons.shopping_bag),
                const SizedBox(height: 20),

                // REVISI: Menampilkan Input Baru untuk Harga Modal (Harga Beli dari Supplier)
                customField(controller: modalC, hint: "Harga Modal / Beli Agen (Angka)", icon: Icons.account_balance_wallet_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 20),

                customField(controller: priceC, hint: "Harga Jual Toko (Angka)", icon: Icons.attach_money, keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                customField(controller: stockC, hint: "Jumlah Stok (Angka)", icon: Icons.inventory, keyboardType: TextInputType.number),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.visibility, color: Colors.grey),
                          SizedBox(width: 15),
                          Text("Status Produk", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Switch(
                        value: isActive,
                        activeColor: AppColor.primary,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isActive ? "*Produk akan tampil di halaman Kasir" : "*Produk disembunyikan dari halaman Kasir",
                  style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: loading ? null : saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Simpan Produk", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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