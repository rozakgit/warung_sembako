// services/report_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil transaksi berdasarkan Hari tertentu
  Stream<List<TransactionModel>> getDailyReport(DateTime date) {
    // Mulai dari 00:00:00 sampai 23:59:59 di hari tersebut
    String start = DateTime(date.year, date.month, date.day).toIso8601String();
    String end = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    return _firestore.collection('transactions')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  // Mengambil transaksi berdasarkan Bulan tertentu
  Stream<List<TransactionModel>> getMonthlyReport(DateTime date) {
    // Mulai dari tanggal 1 sampai hari terakhir di bulan tersebut
    String start = DateTime(date.year, date.month, 1).toIso8601String();
    String end = DateTime(date.year, date.month + 1, 0, 23, 59, 59).toIso8601String();

    return _firestore.collection('transactions')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
}