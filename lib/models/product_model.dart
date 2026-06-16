class ProductModel {
  final String? id;
  final String name;
  final int price;
  final int stock;
  final String image;
  final List<String>? images; // Ditambahkan kembali untuk slider
  final bool isActive;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.image,
    this.images, // Ditambahkan kembali
    this.isActive = true,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      name: data['name'] ?? '',
      price: data['price']?.toInt() ?? 0,
      stock: data['stock']?.toInt() ?? 0,
      image: data['image'] ?? '',
      // Parsing list gambar dari Firebase
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'image': image,
      'images': images ?? [image], // Jika kosong, gunakan gambar utama
      'isActive': isActive,
    };
  }
}