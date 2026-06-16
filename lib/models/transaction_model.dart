// models/transaction_model.dart

class TransactionModel {
  final String? id;
  final String cashierId;
  final int total;
  final String date;
  final List<dynamic> items; // Menyimpan detail produk yang dibeli

  TransactionModel({
    this.id,
    required this.cashierId,
    required this.total,
    required this.date,
    required this.items,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TransactionModel(
      id: documentId,
      cashierId: data['cashierId'] ?? '',
      total: data['total']?.toInt() ?? 0,
      date: data['date'] ?? '',
      items: data['items'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cashierId': cashierId,
      'total': total,
      'date': date,
      'items': items,
    };
  }
}