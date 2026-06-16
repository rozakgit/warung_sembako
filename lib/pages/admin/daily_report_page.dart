// pages/admin/daily_report_page.dart

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../models/transaction_model.dart';
import '../../services/report_service.dart';
import 'monthly_report_page.dart';

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  DateTime selectedDate = DateTime.now();
  final ReportService _reportService = ReportService();

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Laporan Harian", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Lihat Laporan Bulanan",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthlyReportPage()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // HEADER DATE PICKER
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tanggal Laporan", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(
                      "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.edit_calendar, color: Colors.white),
                  label: const Text("Ubah", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // LIST TRANSAKSI & SUMMARY
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: _reportService.getDailyReport(selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Tidak ada transaksi pada tanggal ini.", style: TextStyle(color: Colors.grey)));
                }

                final transactions = snapshot.data!;

                // Hitung Total Pendapatan Harian
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
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Total Pendapatan", style: TextStyle(color: Colors.white70)),
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

                    // DAFTAR STRUK
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final trx = transactions[index];

                          // Format jam transaksi
                          DateTime date = DateTime.parse(trx.date);
                          String jam = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

                          // Rangkuman barang yang dibeli
                          String itemsText = trx.items.map((e) => "${e['name']} (x${e['qty']})").join(", ");

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: AppColor.primary.withOpacity(0.1),
                                child: const Icon(Icons.receipt_long, color: AppColor.primary),
                              ),
                              title: Text("Rp ${trx.total}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(itemsText, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 5),
                                  Text("Jam: $jam", style: const TextStyle(fontSize: 12)),
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