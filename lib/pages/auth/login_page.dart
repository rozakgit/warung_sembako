// pages/auth/login_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../services/auth_service.dart';

import '../dashboard/dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool loading = false;

  bool obscurePassword = true;

  login() async {

    try {

      setState(() {
        loading = true;
      });

      await AuthService().login(

        email: emailC.text,
        password: passC.text,
      );

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (_) =>
          const DashboardPage(),
        ),
      );

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

                      height: 120,
                      width: 120,

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: Padding(

                        padding:
                        const EdgeInsets.all(
                          18,
                        ),

                        child: Image.asset(
                          "assets/icons/logo.png",
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(

                      "Warung Sembako",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight:
                        FontWeight.bold,
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

                      "Login",

                      style: TextStyle(
                        fontSize: 30,
                        fontWeight:
                        FontWeight.bold,
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

                    // LOGIN BUTTON
                    SizedBox(

                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(

                        onPressed:
                        loading ? null : login,

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

                          "Login",

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

                    // REGISTER
                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [

                        const Text(
                          "Belum punya akun?",
                        ),

                        TextButton(

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                const RegisterPage(),
                              ),
                            );

                          },

                          child: const Text(
                            "Register",
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