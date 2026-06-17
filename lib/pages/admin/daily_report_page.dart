// pages/admin/daily_report_page.dart

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../config/app_color.dart';

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  // Rentang tanggal default: Hari Ini
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  // Format Rupiah
  String formatCurrency(int amount) {
    String price = amount.toString();
    String result = '';
    int count = 0;
    for (int i = price.length - 1; i >= 0; i--) {
      count++;
      result = price[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  // Parsing angka aman
  int parseToSafeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return 0;
  }

  // Parsing tanggal aman
  DateTime parseToDateTime(Map<String, dynamic> data) {
    try {
      if (data['createdAt'] != null) {
        if (data['createdAt'] is Timestamp) return (data['createdAt'] as Timestamp).toDate();
        if (data['createdAt'] is String) return DateTime.parse(data['createdAt']);
      }
      if (data['date'] != null) return DateTime.parse(data['date'].toString());
      if (data['timestamp'] != null) {
        if (data['timestamp'] is Timestamp) return (data['timestamp'] as Timestamp).toDate();
        return DateTime.parse(data['timestamp'].toString());
      }
    } catch (e) {
      debugPrint("Tanggal Error: $e");
    }
    return DateTime(2000, 1, 1);
  }

  // Buka Kalender Rentang Tanggal
  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      helpText: 'Pilih Rentang Laporan',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColor.primary, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDateRange = picked);
    }
  }

  // =======================================================
  // FUNGSI CETAK PDF (DENGAN LABA RUGI ASLI)
  // =======================================================
  Future<Uint8List> _generatePdfContent(PdfPageFormat format, List<DocumentSnapshot> docs, int totalOmzet, int totalLaba, int totalModal) async {
    final pdf = pw.Document();
    final tableData = [['No', 'ID Transaksi', 'Waktu', 'Item Belanja', 'Total']];

    int no = 1;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      String id = doc.id.substring(0, 8).toUpperCase();
      DateTime date = parseToDateTime(data);
      String waktu = "${date.day}/${date.month}/${date.year}";

      List<dynamic> items = data['items'] ?? [];
      String itemsText = items.map((e) => "${e['name']} (x${e['qty'] ?? e['quantity'] ?? 1})").join(", ");
      int totalTrx = parseToSafeInt(data['total'] ?? data['totalPrice']);

      tableData.add([no.toString(), id, waktu, itemsText, formatCurrency(totalTrx)]);
      no++;
    }

    String startText = "${selectedDateRange.start.day}/${selectedDateRange.start.month}/${selectedDateRange.start.year}";
    String endText = "${selectedDateRange.end.day}/${selectedDateRange.end.month}/${selectedDateRange.end.year}";
    String periodeTeks = startText == endText ? startText : "$startText s/d $endText";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(child: pw.Text("LAPORAN LABA RUGI WARUNG SEMBAKO", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 5),
            pw.Center(child: pw.Text("Periode: $periodeTeks", style: const pw.TextStyle(fontSize: 14))),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),

            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text("Total Transaksi: ${docs.length} Nota"), pw.Text("Total Omzet: ${formatCurrency(totalOmzet)}")]),
            pw.SizedBox(height: 5),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text("Total Modal Barang: ${formatCurrency(totalModal)}"), pw.Text("LABA BERSIH REAL: ${formatCurrency(totalLaba)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: totalLaba >= 0 ? PdfColors.green800 : PdfColors.red800))]),
            pw.SizedBox(height: 20),

            pw.TableHelper.fromTextArray(
                headers: tableData[0],
                data: tableData.sublist(1),
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                cellAlignments: {0: pw.Alignment.center, 4: pw.Alignment.centerRight}
            ),
          ];
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    String startText = "${selectedDateRange.start.day}/${selectedDateRange.start.month}/${selectedDateRange.start.year}";
    String endText = "${selectedDateRange.end.day}/${selectedDateRange.end.month}/${selectedDateRange.end.year}";
    String displayDate = startText == endText ? startText : "$startText  s/d  $endText";

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(title: const Text("Laporan Keuangan Real", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: AppColor.primary, iconTheme: const IconThemeData(color: Colors.white), elevation: 0),
      body: Column(
        children: [
          // ===============================================
          // FILTER TANGGAL UI
          // ===============================================
          Container(
            padding: const EdgeInsets.all(20), color: Colors.white, width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filter Rentang Tanggal", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, height: 45,
                  child: ElevatedButton.icon(
                    onPressed: _pickDateRange, icon: const Icon(Icons.date_range, color: Colors.white),
                    label: Text(displayDate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ===============================================
          // LIST TRANSAKSI & PERHITUNGAN LABA
          // ===============================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

                var allDocs = snapshot.data?.docs ?? [];

                // 1. FILTER TANGGAL (Anti Bocor Jam/Menit)
                List<DocumentSnapshot> filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  DateTime txDate = parseToDateTime(data);
                  DateTime pureTx = DateTime(txDate.year, txDate.month, txDate.day);
                  DateTime start = DateTime(selectedDateRange.start.year, selectedDateRange.start.month, selectedDateRange.start.day);
                  DateTime end = DateTime(selectedDateRange.end.year, selectedDateRange.end.month, selectedDateRange.end.day);
                  return (pureTx.isAfter(start) || pureTx.isAtSameMomentAs(start)) && (pureTx.isBefore(end) || pureTx.isAtSameMomentAs(end));
                }).toList();

                // Sort Terbaru
                filteredDocs.sort((a, b) => parseToDateTime(b.data() as Map<String, dynamic>).compareTo(parseToDateTime(a.data() as Map<String, dynamic>)));

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        const Text("Tidak ada transaksi pada periode ini.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // =======================================================
                // 2. HITUNG OMZET & LABA BERSIH ASLI (BERDASARKAN COST PRICE)
                // =======================================================
                int totalOmzet = 0;
                int totalModalAsli = 0;

                for (var doc in filteredDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  totalOmzet += parseToSafeInt(data['total'] ?? data['totalPrice']);

                  List<dynamic> items = data['items'] ?? [];
                  for (var item in items) {
                    int qty = parseToSafeInt(item['quantity'] ?? item['qty']);
                    // Membaca modal barang yang terkunci saat checkout. Jika data lama kosong, anggap 0.
                    int modalBarang = parseToSafeInt(item['costPrice'] ?? item['modal']);
                    totalModalAsli += (qty * modalBarang);
                  }
                }

                int labaBersihAsli = totalOmzet - totalModalAsli;

                return Column(
                  children: [
                    // KARTU AUDIT LABA RUGI
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColor.primary, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(labaBersihAsli >= 0 ? "Keuntungan Bersih" : "Kerugian Bersih", style: const TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 5),
                                    Text(formatCurrency(labaBersihAsli), style: TextStyle(color: labaBersihAsli >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: Text("${filteredDocs.length} Trx", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Omzet: ${formatCurrency(totalOmzet)}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                                Text("Total Modal: ${formatCurrency(totalModalAsli)}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                            const Divider(color: Colors.white30, height: 25),

                            // TOMBOL BUKA PREVIEW PDF
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => Scaffold(
                                              appBar: AppBar(title: const Text("Pratinjau PDF", style: TextStyle(color: Colors.white)), backgroundColor: AppColor.primary, iconTheme: const IconThemeData(color: Colors.white)),
                                              body: PdfPreview(build: (f) => _generatePdfContent(f, filteredDocs, totalOmzet, labaBersihAsli, totalModalAsli))
                                          )
                                      )
                                  );
                                },
                                icon: const Icon(Icons.picture_as_pdf, color: AppColor.primary), label: const Text("Lihat Dokumen PDF", style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // LIST VIEW HISTORI NOTA
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          DateTime date = parseToDateTime(data);

                          List<dynamic> items = data['items'] ?? [];
                          String itemsText = items.map((e) => "${e['name']} (x${e['qty'] ?? e['quantity'] ?? 1})").join(", ");
                          int trxTotal = parseToSafeInt(data['total'] ?? data['totalPrice']);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(backgroundColor: AppColor.primary.withOpacity(0.1), child: const Icon(Icons.receipt_long, color: AppColor.primary)),
                              title: Text(formatCurrency(trxTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(itemsText, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 5),
                                  Text("Tgl: ${date.day}/${date.month}/${date.year} - Jam: ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}", style: const TextStyle(fontSize: 11)),
                                ],
                              ),
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