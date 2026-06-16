// pages/admin/user_management_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/user_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserService userService = UserService();
  final TextEditingController searchController = TextEditingController();

  String keyword = '';

  // Fungsi Tampilkan Form Dialog Tambah User Baru
  void showAddUserDialog() {
    final addNameC = TextEditingController();
    final addUsernameC = TextEditingController();
    final addPhoneC = TextEditingController();
    final addEmailC = TextEditingController();
    final addPassC = TextEditingController();
    String addRole = "cashier";
    bool dialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Tambah Pengguna Baru", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: addNameC,
                      decoration: const InputDecoration(hintText: "Nama Lengkap", prefixIcon: Icon(Icons.person)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addUsernameC,
                      decoration: const InputDecoration(hintText: "Username", prefixIcon: Icon(Icons.alternate_email)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addPhoneC,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: "Nomor HP", prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addEmailC,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: "Email", prefixIcon: Icon(Icons.email)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addPassC,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: "Password", prefixIcon: Icon(Icons.lock)),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: addRole,
                      decoration: const InputDecoration(labelText: "Role Akses", prefixIcon: Icon(Icons.admin_panel_settings)),
                      items: const [
                        DropdownMenuItem(value: "admin", child: Text("Admin")),
                        DropdownMenuItem(value: "cashier", child: Text("Kasir")),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          addRole = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading ? null : () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                  onPressed: dialogLoading
                      ? null
                      : () async {
                    if (addNameC.text.isEmpty || addEmailC.text.isEmpty || addPassC.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nama, Email, dan Password wajib diisi!")),
                      );
                      return;
                    }

                    try {
                      setDialogState(() {
                        dialogLoading = true;
                      });

                      await userService.createUserByAdmin(
                        name: addNameC.text,
                        username: addUsernameC.text,
                        phone: addPhoneC.text,
                        email: addEmailC.text,
                        password: addPassC.text,
                        role: addRole,
                      );

                      if (!mounted) return;
                      Navigator.pop(context); // Tutup Dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pengguna baru Berhasil ditambahkan!")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal mendaftar: ${e.toString()}")),
                      );
                    } finally {
                      setDialogState(() {
                        dialogLoading = false;
                      });
                    }
                  },
                  child: dialogLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text(
          "Kelola Pengguna",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // TOMBOL FLOATING UNTUK TAMBAH USER LANGSUNG OLEH ADMIN
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        onPressed: showAddUserDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Cari nama pengguna...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  keyword = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: userService.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Belum ada data pengguna."),
                  );
                }

                var users = snapshot.data!;

                if (keyword.isNotEmpty) {
                  users = users.where((user) {
                    final name = user.name.toLowerCase();
                    return name.contains(keyword);
                  }).toList();
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: UserCard(
                        name: user.name,
                        email: user.email,
                        role: user.role,
                        onTap: () {
                          showUserDetail(user);
                        },
                      ),
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

  void showUserDetail(UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 35,
                backgroundColor: AppColor.primary,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.email,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user.role == 'admin' ? Colors.blue.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: TextStyle(
                    color: user.role == 'admin' ? Colors.blue.shade800 : Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await userService.updateRole(
                      user.uid,
                      user.role == 'admin' ? 'cashier' : 'admin',
                    );
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  label: Text(
                    user.role == 'admin' ? "Ubah jadi Kasir" : "Jadikan Admin",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await userService.deleteUser(user.uid);
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  label: const Text(
                    "Hapus Akun",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}