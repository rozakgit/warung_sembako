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

  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool loading = false;

  bool obscurePassword = true;

  register() async {

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColor.primary,

      body: SafeArea(

        child: SingleChildScrollView(

          child: Column(

            children: [

              // =========================
              // HEADER
              // =========================

              Container(

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 50,
                ),

                child: Column(

                  children: [

                    // LOGO
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

                    const SizedBox(height: 25),

                    const Text(

                      "Buat Akun Baru",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(

                      "Daftar dan mulai belanja kebutuhan harian",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // FORM
              // =========================

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

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(

                      "Register",

                      style: TextStyle(
                        fontSize: 30,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(

                      "Silahkan buat akun baru",

                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // EMAIL
                    TextField(

                      controller: emailC,

                      decoration: InputDecoration(

                        hintText: "Email",

                        prefixIcon: const Icon(
                          Icons.email,
                        ),

                        filled: true,

                        fillColor:
                        AppColor.background,

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),

                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    TextField(

                      controller: passC,

                      obscureText:
                      obscurePassword,

                      decoration: InputDecoration(

                        hintText: "Password",

                        prefixIcon: const Icon(
                          Icons.lock,
                        ),

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

                        filled: true,

                        fillColor:
                        AppColor.background,

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),

                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // REGISTER BUTTON
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

                    // LOGIN
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