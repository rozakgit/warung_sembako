import 'package:flutter/material.dart';

  void addToCart(String name, int price) {
    setState(() {
      cart.add({
        'name': name,
        'price': price,
        'qty': 1,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Beras'),
                  subtitle: const Text('Rp 15.000'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      addToCart('Beras', 15000);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Gula'),
                  subtitle: const Text('Rp 12.000'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      addToCart('Gula', 12000);
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Total: Rp $total',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaksi berhasil'),
                      ),
                    );
                  },
                  child: const Text('Bayar'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
