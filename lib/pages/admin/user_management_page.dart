// pages/admin/user_management_page.dart

import 'package:flutter/material.dart';

import '../../models/user_model.dart'; // Pastikan Model di-import
import '../../services/user_service.dart';
import '../../widgets/user_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({
    super.key,
  });

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserService userService = UserService();
  final TextEditingController searchController = TextEditingController();

  String keyword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Pengguna"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Cari pengguna...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  keyword = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            // 1. Ubah tipe StreamBuilder menjadi List<UserModel>
            child: StreamBuilder<List<UserModel>>(
              stream: userService.getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // 2. Data yang diterima sekarang adalah List<UserModel>
                var users = snapshot.data!;

                users = users.where((user) {
                  // 3. Akses property model (user.name) bukan map (user['name'])
                  final name = user.name.toLowerCase();
                  return name.contains(keyword);
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];

                    return UserCard(
                      name: user.name,
                      email: user.email,
                      role: user.role,
                      onTap: () {
                        showUserDetail(user);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 4. Ubah tipe parameter menjadi UserModel
  void showUserDetail(UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(user.email),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // 5. Gunakan positional parameters untuk updateRole
                  await userService.updateRole(
                    user.uid,
                    user.role == 'admin' ? 'cashier' : 'admin',
                  );

                  Navigator.pop(context);
                },
                child: const Text(
                  "Ubah Role",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  // 6. Gunakan user.uid untuk deleteUser
                  await userService.deleteUser(user.uid);

                  Navigator.pop(context);
                },
                child: const Text(
                  "Hapus User",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}