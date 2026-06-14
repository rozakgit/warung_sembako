import 'package:flutter/material.dart';

class DailyReportPage extends StatelessWidget {
  const DailyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian'),
      ),
      body: const Center(
        child: Text('Laporan Harian'),
      ),
    );
  }
}