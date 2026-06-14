import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/product_service.dart';

class ProductManagementPage
    extends StatefulWidget {

  const ProductManagementPage({
    super.key,
  });

  @override
  State<ProductManagementPage>
  createState() =>
      _ProductManagementPageState();
}

class _ProductManagementPageState
    extends State<ProductManagementPage> {

  final ProductService productService =
  ProductService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text("Kelola Produk"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
        productService.getProducts(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          var products =
              snapshot.data!.docs;

          return ListView.builder(

            itemCount: products.length,

            itemBuilder: (context, index) {

              var product =
              products[index];

              return Card(

                margin:
                const EdgeInsets.all(
                  10,
                ),

                child: ListTile(

                  leading: const Icon(
                    Icons.shopping_bag,
                  ),

                  title: Text(
                    product['name'],
                  ),

                  subtitle: Text(
                    "Rp ${product['price']}",
                  ),

                  trailing: Row(

                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      Switch(

                        value:
                        product['isActive'],

                        onChanged:
                            (value) {

                          productService
                              .toggleStatus(

                            docId:
                            product.id,

                            currentStatus:
                            product[
                            'isActive'],
                          );
                        },
                      ),

                      IconButton(

                        icon:
                        const Icon(
                          Icons.edit,
                        ),

                        onPressed:
                            () {},
                      ),

                      IconButton(

                        icon:
                        const Icon(
                          Icons.delete,
                          color:
                          Colors.red,
                        ),

                        onPressed:
                            () {

                          productService
                              .deleteProduct(
                            product.id,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton:
      FloatingActionButton(

        child: const Icon(Icons.add),

        onPressed: () {

          showAddProductDialog();
        },
      ),
    );
  }

  void showAddProductDialog() {

    final nameC =
    TextEditingController();

    final priceC =
    TextEditingController();

    final stockC =
    TextEditingController();

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title:
          const Text("Tambah Produk"),

          content: Column(

            mainAxisSize:
            MainAxisSize.min,

            children: [

              TextField(
                controller: nameC,
                decoration:
                const InputDecoration(
                  hintText:
                  "Nama Produk",
                ),
              ),

              TextField(
                controller: priceC,
                decoration:
                const InputDecoration(
                  hintText: "Harga",
                ),
              ),

              TextField(
                controller: stockC,
                decoration:
                const InputDecoration(
                  hintText: "Stok",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                );
              },

              child:
              const Text("Batal"),
            ),

            ElevatedButton(

              onPressed: () async {

                await productService
                    .addProduct(

                  name: nameC.text,

                  price: priceC.text,

                  stock: stockC.text,

                  image: "",
                );

                Navigator.pop(
                  context,
                );
              },

              child:
              const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}