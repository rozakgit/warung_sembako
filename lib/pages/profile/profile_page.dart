// pages/profile/profile_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Memuat nama...";
  String email = "Memuat email...";
  String phone = "-";
  String role = "cashier";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Ambil data profil dari Firestore secara realtime
  void _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        email = user.email ?? "-";

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            name = doc.data()?['name'] ?? "User Sembako";
            role = doc.data()?['role'] ?? "cashier";
            phone = doc.data()?['phone'] ?? "-";
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat profil: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profil Saya",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            // CARD KARTU NAMA USER ELEGAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColor.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 70, color: AppColor.primary),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  if (phone != "-") ...[
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: role == 'admin' ? Colors.orange.shade50 : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: role == 'admin' ? Colors.orange : Colors.teal, width: 1),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        color: role == 'admin' ? Colors.orange.shade800 : Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // GRUP MENU PENGATURAN AKUN
            profileMenu(
              icon: Icons.edit_outlined,
              title: "Edit Profil Akun",
              subtitle: "Ubah nama lengkap dan nomor telepon pegawai",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(currentName: name, currentPhone: phone),
                  ),
                ).then((_) => _loadUserProfile()); // Refresh data saat kembali
              },
            ),
            profileMenu(
              icon: Icons.lock_reset_outlined,
              title: "Ganti Password Keamanan",
              subtitle: "Perbarui kata sandi enkripsi akun berkala",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              },
            ),
            profileMenu(
              icon: Icons.info_outline_rounded,
              title: "Tentang Aplikasi",
              subtitle: "Informasi versi sistem warung & pengembang",
              onTap: () => _showAboutDialog(context), // REVISI: Sekarang memanggil Dialog Tengah
            ),

            const SizedBox(height: 30),

            // TOMBOL LOGOUT
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text("Keluar Sesi Akun (Logout)", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: AppColor.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ============================================================================
  // REVISI: DIALOG TENTANG APLIKASI TAMPIL DI TENGAH LAYAR
  // ============================================================================
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Atas Elegan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, color: AppColor.primary, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tentang Aplikasi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Warung Sembako Pro v2.0",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sistem manajemen Point of Sales (POS) kasir pintar mandiri dan pemantauan stok pergudangan secara realtime terintegrasi cloud database.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
            ),
            const Divider(height: 35),
            const Text(
              "Pengembang Sistem:",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              "Muhammad Abdul Rozak dan Felan Ardeta Yoga Adiyatama",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              "Jurusan Teknik Informatika",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 25),

            // Tombol Tutup Modern Full Width
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Tutup",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DEDICATED SCREEN 1: HALAMAN EDIT PROFIL KHUSUS (FULL SCREEN)
// ============================================================================
class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  const EditProfileScreen({super.key, required this.currentName, required this.currentPhone});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameC;
  late TextEditingController phoneC;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.currentName);
    phoneC = TextEditingController(text: widget.currentPhone == "-" ? "" : widget.currentPhone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Ubah Profil Akun", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(25),
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informasi Pegawai", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // FIELD NAMA LENGKAP
                  TextFormField(
                    controller: nameC,
                    validator: (v) => v!.trim().isEmpty ? "Nama lengkap wajib diisi" : null,
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FIELD NOMOR TELEPON
                  TextFormField(
                    controller: phoneC,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.trim().isEmpty ? "Nomor telepon wajib diisi" : null,
                    decoration: InputDecoration(
                      labelText: "Nomor WhatsApp / HP",
                      prefixIcon: const Icon(Icons.phone_android_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: isSaving ? null : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => isSaving = true);
                  try {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({
                        'name': nameC.text.trim(),
                        'phone': phoneC.text.trim(),
                      });
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil sukses diperbarui!")));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                  } finally {
                    setState(() => isSaving = false);
                  }
                },
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DEDICATED SCREEN 2: HALAMAN GANTI PASSWORD AMAN DENGAN RE-AUTENTIKASI
// ============================================================================
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final oldPassC = TextEditingController();
  final newPassC = TextEditingController();
  final confirmPassC = TextEditingController();

  bool _secureOld = true;
  bool _secureNew = true;
  bool _secureConfirm = true;
  bool isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Ganti Keamanan Sandi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(25),
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Formulir Pembaharuan Sandi", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // PASSWORD LAMA (Wajib re-auth)
                  TextFormField(
                    controller: oldPassC,
                    obscureText: _secureOld,
                    validator: (v) => v!.isEmpty ? "Masukkan password saat ini" : null,
                    decoration: InputDecoration(
                      labelText: "Password Saat Ini",
                      prefixIcon: const Icon(Icons.lock_open_rounded),
                      suffixIcon: IconButton(icon: Icon(_secureOld ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _secureOld = !_secureOld)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const Divider(height: 40),

                  // PASSWORD BARU
                  TextFormField(
                    controller: newPassC,
                    obscureText: _secureNew,
                    validator: (v) => v!.length < 6 ? "Password baru minimal 6 karakter" : null,
                    decoration: InputDecoration(
                      labelText: "Password Baru (Min 6 Karakter)",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(icon: Icon(_secureNew ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _secureNew = !_secureNew)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // KONFIRMASI PASSWORD BARU
                  TextFormField(
                    controller: confirmPassC,
                    obscureText: _secureConfirm,
                    validator: (v) => v != newPassC.text ? "Konfirmasi sandi tidak sesuai" : null,
                    decoration: InputDecoration(
                      labelText: "Ulangi Password Baru",
                      prefixIcon: const Icon(Icons.verified_user_outlined),
                      suffixIcon: IconButton(icon: Icon(_secureConfirm ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _secureConfirm = !_secureConfirm)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: isUpdating ? null : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => isUpdating = true);

                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && user.email != null) {
                      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: oldPassC.text.trim());
                      await user.reauthenticateWithCredential(credential);
                      await user.updatePassword(newPassC.text.trim());

                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sandi sukses diperbarui!")));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verifikasi Gagal: Password lama salah atau sesi kedaluwarsa.")));
                  } finally {
                    setState(() => isUpdating = false);
                  }
                },
                child: isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Perbarui Password Akun", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}