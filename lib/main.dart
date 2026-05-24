import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warung Sembako',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/admin': (context) => const AdminPage(),
        '/cashier': (context) => const CashierPage(),
      },
    );
  }
}