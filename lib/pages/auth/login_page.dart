// pages/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Wajib untuk fitur reset password
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/app_color.dart';
import '../../services/auth_service.dart';

// Import DashboardPage sebagai tujuan utama
import '../dashboard/dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  // ========================================================
  // FITUR 1: FUNGSI MENAMPILKAN POP-UP ERROR CUSTOM
  // ========================================================
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Login Gagal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Coba Lagi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          )
        ],
      ),
    );
  }

  // ========================================================
  // FITUR 2: DIALOG POP-UP LUPA PASSWORD
  // ========================================================
  void _showForgotPasswordDialog() {
    final resetEmailC = TextEditingController(text: emailC.text);
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: AppColor.primary, size: 28),
                  SizedBox(width: 10),
                  Text("Reset Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Masukkan email Anda yang terdaftar. Sistem akan mengirimkan tautan verifikasi pengaturan ulang kata sandi ke kotak masuk Anda.",
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email Pengguna",
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: AppColor.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isSending
                      ? null
                      : () async {
                    if (resetEmailC.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email wajib diisi!")),
                      );
                      return;
                    }

                    try {
                      setDialogState(() {
                        isSending = true;
                      });

                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: resetEmailC.text.trim(),
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context); // Tutup dialog

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tautan reset password sukses dikirim! Cek email Anda."),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      String errorMsg = "Gagal mengirim email reset.";
                      if (e.toString().contains('user-not-found')) {
                        errorMsg = "Email tersebut tidak terdaftar dalam sistem.";
                      } else if (e.toString().contains('invalid-email')) {
                        errorMsg = "Format penulisan email salah.";
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                      );
                    } finally {
                      setDialogState(() {
                        isSending = false;
                      });
                    }
                  },
                  child: isSending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text("Kirim Link", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========================================================
  // LOGIC UTAMA: PROSES LOGIN KE SISTEM
  // ========================================================
  login() async {
    if (emailC.text.trim().isEmpty || passC.text.trim().isEmpty) {
      _showErrorDialog("Email dan Password tidak boleh kosong. Silakan isi terlebih dahulu!");
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final user = await AuthService().login(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        // Cek Verifikasi 2 Langkah (Untuk Kasir)
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

          if (userDoc.exists) {
            String role = userDoc.data()?['role'] ?? 'cashier';
            bool isApproved = userDoc.data()?['isApproved'] ?? false;

            if (role == 'cashier' && !isApproved) {
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Row(
                    children: [
                      Icon(Icons.gpp_maybe, color: Colors.red, size: 30),
                      SizedBox(width: 10),
                      Text("Akses Ditangguhkan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  content: const Text("Akun Kasir Anda saat ini berstatus PENDING karena belum diverifikasi oleh Pemilik Warung (Admin). Silakan hubungi Admin untuk aktivasi."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Mengerti", style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary)),
                    )
                  ],
                ),
              );
              return;
            }
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardPage(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString().toLowerCase();
      String displayMessage = "Terjadi kesalahan sistem. Silakan coba lagi nanti.";

      if (errorMsg.contains('user-not-found') || errorMsg.contains('invalid-email')) {
        displayMessage = "Email yang Anda masukkan tidak terdaftar atau formatnya salah.";
      } else if (errorMsg.contains('wrong-password') || errorMsg.contains('invalid-credential') || errorMsg.contains('invalid-login-credentials')) {
        displayMessage = "Kombinasi Email dan Password tidak cocok / salah.";
      } else if (errorMsg.contains('network-request-failed')) {
        displayMessage = "Tidak ada koneksi internet. Periksa jaringan Anda.";
      } else if (errorMsg.contains('too-many-requests')) {
        displayMessage = "Terlalu banyak percobaan gagal. Akses diblokir sementara, coba lagi nanti.";
      } else {
        displayMessage = e.toString().replaceAll("Exception: ", "").replaceAll(RegExp(r'\[.*?\]'), '').trim();
      }

      _showErrorDialog(displayMessage);

    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
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
                  vertical: 50,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 130,
                      width: 130,
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
                    const SizedBox(height: 25),
                    const Text(
                      "Warung Sembako",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Belanja kebutuhan harian lebih mudah",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // FORM LOGIN
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Masuk ke akun anda",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // EMAIL FIELD
                    TextField(
                      controller: emailC,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: AppColor.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PASSWORD FIELD
                    TextField(
                      controller: passC,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock),
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
                        filled: true,
                        fillColor: AppColor.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ===========================================
                    // FITUR KEMBALI: TOMBOL "LUPA PASSWORD"
                    // ===========================================
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          "Lupa Password?",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // REGISTER LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum punya akun?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text("Register"),
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