// pages/cashier/receipt_page.dart

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../config/app_color.dart';

class ReceiptPage extends StatelessWidget {
  final String transactionId;
  final int total;
  final List<dynamic> items;

  const ReceiptPage({
    super.key,
    required this.transactionId,
    required this.total,
    required this.items,
  });

  // =======================================================
  // FUNGSI CETAK: DESAIN STRUK THERMAL PREMIUM (ROLL 57mm)
  // =======================================================
  void _printReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        margin: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Toko
              pw.Center(
                child: pw.Text("WARUNG SEMBAKO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
              ),
              pw.Center(
                child: pw.Text("Penyedia Kebutuhan Pokok Keluarga", style: pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic)),
              ),
              pw.Center(
                child: pw.Text("Terpercaya & Murah", style: pw.TextStyle(fontSize: 6.5)),
              ),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.8),

              // Metadata Transaksi
              pw.Text("No. Struk : ${transactionId.substring(0, txIdLength(transactionId))}", style: pw.TextStyle(fontSize: 7)),
              pw.Text("Tanggal  : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}", style: pw.TextStyle(fontSize: 7)),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.8),

              // Daftar Item Belanjaan
              pw.ListView.builder(
                itemCount: items.length,
                itemBuilder: (pw.Context context, int index) {
                  final item = items[index];
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.product.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("${item.quantity} x Rp ${item.product.price}", style: pw.TextStyle(fontSize: 7.5)),
                            pw.Text("Rp ${item.subtotal}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.8),

              // Total Belanja
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  pw.Text("Rp $total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                ],
              ),

              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.8),
              pw.SizedBox(height: 5),

              // Footer
              pw.Center(
                child: pw.Text("Sembako Masuk, Dapur Ngebul!", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text("Terima kasih atas kunjungan Anda", style: pw.TextStyle(fontSize: 6.5, fontStyle: pw.FontStyle.italic)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Struk-$transactionId',
    );
  }

  int txIdLength(String id) => id.length > 8 ? 8 : id.length;

  // =======================================================
  // TAMPILAN LAYAR: DIGITAL INVOICE CARD STYLE
  // =======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Icon Animasi Sukses Gede & Cantik
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 85,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Transaksi Sukses!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 30),

              // DIGITAL INVOICE CARD
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sesi Atas: Nominal
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Pembayaran",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Rp $total",
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Garis Pembatas Estetik Ala Tiket / Nota
                    Row(
                      children: List.generate(
                        30,
                            (index) => Expanded(
                          child: Container(
                            color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200,
                            height: 2,
                          ),
                        ),
                      ),
                    ),

                    // Sesi Bawah: Detail rincian transaksi
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          _buildDetailRow("ID Transaksi", "#${transactionId.substring(0, txIdLength(transactionId)).toUpperCase()}"),
                          const SizedBox(height: 15),
                          _buildDetailRow("Metode", "Tunai / Cash"),
                          const SizedBox(height: 15),
                          _buildDetailRow("Waktu", "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} WIB"),
                          const SizedBox(height: 15),
                          _buildDetailRow("Jumlah Barang", "${items.length} Macam"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // ==========================================
              // ACTION BUTTONS (TOMBOL AKSI)
              // ==========================================
              // Tombol Cetak Struk
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _printReceipt,
                  icon: const Icon(Icons.print_rounded, color: Colors.white, size: 24),
                  label: const Text(
                    "Cetak Struk Fisik",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Kembali Ke Beranda
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColor.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_rounded, color: AppColor.primary),
                  label: const Text(
                    "Kembali ke Beranda",
                    style: TextStyle(color: AppColor.primary, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembantu untuk baris detail digital invoice
  // Widget pembantu untuk baris detail digital invoice
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87, // <-- Sudah diperbaiki menjadi black87 saja
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}