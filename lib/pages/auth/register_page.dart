// pages/auth/register_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahan untuk akses Firestore langsung
import 'login_page.dart';
import '../../config/app_color.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameC = TextEditingController();
  final usernameC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();

  bool loading = false;
  String selectedRole = "cashier";
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  register() async {
    if (passC.text != confirmPassC.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konfirmasi password tidak sama"),
        ),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      // 1. Simpan data awal ke Firebase via AuthService
      await AuthService().register(
        name: nameC.text,
        username: usernameC.text,
        phone: phoneC.text,
        email: emailC.text,
        password: passC.text,
        role: selectedRole,
      );

      // ====================================================================
      // REVISI: INJEKSI STATUS APPROVAL SECARA REALTIME UNTUK KASIR
      // ====================================================================
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'isApproved': selectedRole == 'admin' ? true : false, // Admin langsung aktif, Kasir butuh verifikasi
        });
      }

      if (!mounted) return;

      // 2. Tampilkan pesan berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selectedRole == 'cashier'
              ? "Pendaftaran berhasil! Tunggu verifikasi/persetujuan Admin."
              : "Register Admin berhasil, silakan Login"),
          backgroundColor: Colors.green,
        ),
      );

      // 3. Paksa pindah ke halaman login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = "Terjadi kesalahan";

      if (e.code == 'email-already-in-use') {
        errorMessage = "Email ini sudah terdaftar. Silakan gunakan email lain.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password terlalu lemah. Gunakan minimal 6 karakter.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Format email tidak valid.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('email-already-in-use')
                ? "Email ini sudah terdaftar. Silakan gunakan email lain."
                : "Gagal mendaftar: ${e.toString()}",
          ),
        ),
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
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColor.background,
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
      backgroundColor: AppColor.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    // LOGO
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/icons/logo.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: "Role Hak Akses",
                        prefixIcon: const Icon(
                          Icons.admin_panel_settings,
                        ),
                        filled: true,
                        fillColor: AppColor.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "admin",
                          child: Text("Admin (Pemilik)"),
                        ),
                        DropdownMenuItem(
                          value: "cashier",
                          child: Text("Kasir (Pegawai)"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Buat Akun Baru",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Daftar kasir baru wajib diverifikasi pemilik warung",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // FORM REGISTRASI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    customField(
                      controller: nameC,
                      hint: "Nama Lengkap",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),
                    customField(
                      controller: usernameC,
                      hint: "Username",
                      icon: Icons.alternate_email,
                    ),
                    const SizedBox(height: 20),
                    customField(
                      controller: phoneC,
                      hint: "Nomor HP",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    customField(
                      controller: emailC,
                      hint: "Email",
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    customField(
                      controller: passC,
                      hint: "Password",
                      icon: Icons.lock,
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    customField(
                      controller: confirmPassC,
                      hint: "Konfirmasi Password",
                      icon: Icons.lock,
                      obscureText: obscureConfirmPassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Daftar Akun Baru",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sudah punya akun?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Login"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}