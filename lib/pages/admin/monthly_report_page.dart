// pages/admin/monthly_report_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/transaction_model.dart';
import '../../services/report_service.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  DateTime selectedMonth = DateTime.now();
  final ReportService _reportService = ReportService();

  final List<String> namaBulan = [
    "", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Laporan Bulanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange, // Dibedakan warnanya dengan harian
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // HEADER MONTH SELECTOR
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
                  onPressed: _previousMonth,
                ),
                Text(
                  "${namaBulan[selectedMonth.month]} ${selectedMonth.year}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // LIST TRANSAKSI & SUMMARY
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: _reportService.getMonthlyReport(selectedMonth),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Tidak ada transaksi pada bulan ini.", style: TextStyle(color: Colors.grey)));
                }

                final transactions = snapshot.data!;

                int totalPendapatan = 0;
                for (var t in transactions) {
                  totalPendapatan += t.total;
                }

                return Column(
                  children: [
                    // KOTAK RINGKASAN
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Pendapatan Bulanan", style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 5),
                                Text(
                                  "Rp $totalPendapatan",
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${transactions.length} Trx",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DAFTAR STRUK BULANAN
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final trx = transactions[index];

                          DateTime date = DateTime.parse(trx.date);
                          String tgl = "${date.day} ${namaBulan[date.month]}";

                          String itemsText = trx.items.map((e) => "${e['name']} (x${e['qty']})").join(", ");

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withOpacity(0.1),
                                child: const Icon(Icons.date_range, color: Colors.orange),
                              ),
                              title: Text("Rp ${trx.total}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(itemsText, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 5),
                                  Text("Tgl: $tgl", style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}