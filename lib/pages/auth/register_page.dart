// pages/auth/register_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  final nameC = TextEditingController();
  final usernameC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC =
  TextEditingController();

  bool loading = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  register() async {

    if (passC.text !=
        confirmPassC.text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Konfirmasi password tidak sama",
          ),
        ),
      );

      return;
    }

    try {

      setState(() {
        loading = true;
      });

      await AuthService().register(

        email: emailC.text,
        password: passC.text,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Register berhasil",
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

    }

    setState(() {
      loading = false;
    });

  }

  Widget customField({

    required TextEditingController controller,
    required String hint,
    required IconData icon,

    bool obscureText = false,

    Widget? suffixIcon,

    TextInputType keyboardType =
        TextInputType.text,

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

          borderRadius:
          BorderRadius.circular(18),

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

                padding:
                const EdgeInsets.symmetric(
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

                            color:
                            Colors.black.withOpacity(
                              0.15,
                            ),

                            blurRadius: 15,

                            offset:
                            const Offset(0, 8),
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

                    const Text(

                      "Buat Akun Baru",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(

                      "Daftar dan mulai belanja sekarang",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // FORM
              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(25),

                decoration: const BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.vertical(
                    top: Radius.circular(35),
                  ),
                ),

                child: Column(

                  children: [

                    // NAMA
                    customField(

                      controller: nameC,

                      hint: "Nama Lengkap",

                      icon: Icons.person,
                    ),

                    const SizedBox(height: 20),

                    // USERNAME
                    customField(

                      controller: usernameC,

                      hint: "Username",

                      icon: Icons.alternate_email,
                    ),

                    const SizedBox(height: 20),

                    // PHONE
                    customField(

                      controller: phoneC,

                      hint: "Nomor HP",

                      icon: Icons.phone,

                      keyboardType:
                      TextInputType.phone,
                    ),

                    const SizedBox(height: 20),

                    // EMAIL
                    customField(

                      controller: emailC,

                      hint: "Email",

                      icon: Icons.email,
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    customField(

                      controller: passC,

                      hint: "Password",

                      icon: Icons.lock,

                      obscureText:
                      obscurePassword,

                      suffixIcon: IconButton(

                        onPressed: () {

                          setState(() {

                            obscurePassword =
                            !obscurePassword;

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

                    // CONFIRM PASSWORD
                    customField(

                      controller:
                      confirmPassC,

                      hint:
                      "Konfirmasi Password",

                      icon: Icons.lock,

                      obscureText:
                      obscureConfirmPassword,

                      suffixIcon: IconButton(

                        onPressed: () {

                          setState(() {

                            obscureConfirmPassword =
                            !obscureConfirmPassword;

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

                    // BUTTON
                    SizedBox(

                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(

                        onPressed:
                        loading ? null : register,

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          AppColor.primary,

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                          ),
                        ),

                        child: loading

                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )

                            : const Text(

                          "Register",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [

                        const Text(
                          "Sudah punya akun?",
                        ),

                        TextButton(

                          onPressed: () {

                            Navigator.pop(
                              context,
                            );

                          },

                          child: const Text(
                            "Login",
                          ),
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