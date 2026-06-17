// pages/admin/user_management_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserService userService = UserService();
  final TextEditingController searchController = TextEditingController();
  String keyword = '';

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

                      // Buat Akun via Auth & Firestore
                      await userService.createUserByAdmin(
                        name: addNameC.text,
                        username: addUsernameC.text,
                        phone: addPhoneC.text,
                        email: addEmailC.text,
                        password: addPassC.text,
                        role: addRole,
                      );

                      // REVISI LOGIKA: Akun buatan Admin langsung otomatis Aktif (isApproved = true)
                      final query = await FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: addEmailC.text.trim())
                          .get();
                      if (query.docs.isNotEmpty) {
                        await query.docs.first.reference.update({'isApproved': true});
                      }

                      if (!mounted) return;
                      Navigator.pop(context);
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
            // REVISI: Menggunakan QuerySnapshot agar pembacaan dinamis isApproved lancar jaya
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                var docs = snapshot.data?.docs ?? [];

                // Filter keyword pencarian
                if (keyword.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(keyword);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(child: Text("Belum ada data pengguna."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String uid = doc.id;
                    final String name = data['name'] ?? '-';
                    final String email = data['email'] ?? '-';
                    final String role = data['role'] ?? 'cashier';
                    final bool isApproved = data['isApproved'] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: role == 'admin' ? Colors.orange.shade100 : Colors.teal.shade100,
                          child: Icon(role == 'admin' ? Icons.admin_panel_settings : Icons.person, color: role == 'admin' ? Colors.orange : Colors.teal),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Text(role.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: role == 'admin' ? Colors.orange : Colors.teal)),
                              const Text(" | ", style: TextStyle(color: Colors.grey)),

                              // BADGE STATUS VERIFIKASI
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isApproved ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isApproved ? "AKTIF" : "PENDING",
                                  style: TextStyle(color: isApproved ? Colors.green.shade700 : Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => showUserDetail(uid, name, email, role, isApproved),
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

  void showUserDetail(String uid, String name, String email, String role, bool isApproved) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 35,
                backgroundColor: isApproved ? AppColor.primary : Colors.grey,
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 15),

              // ====================================================================
              // REVISI TOMBOL AKSI UTAMA: PERSETUJUAN VERIFIKASI (APPROVE / REVOKE)
              // ====================================================================
              if (role == 'cashier')
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(isApproved ? Icons.block : Icons.check_circle, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApproved ? Colors.orange.shade700 : Colors.green.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      // Mengubah status persetujuan di database Firestore secara langsung
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({
                        'isApproved': !isApproved,
                      });
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isApproved ? "Akses Kasir berhasil Dinonaktifkan!" : "Akun Kasir berhasil Diverifikasi & Aktif!")),
                      );
                    },
                    label: Text(
                      isApproved ? "Nonaktifkan Akses Kasir" : "Setujui / Verifikasi Kasir",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              if (role == 'cashier') const SizedBox(height: 12),

              // TOMBOL ATUR ROLE
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await userService.updateRole(uid, role == 'admin' ? 'cashier' : 'admin');
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  label: Text(role == 'admin' ? "Ubah jadi Kasir" : "Jadikan Admin", style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),

              // TOMBOL HAPUS AKUN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await userService.deleteUser(uid);
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  label: const Text("Hapus Akun Permanen", style: TextStyle(color: Colors.white, fontSize: 16)),
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