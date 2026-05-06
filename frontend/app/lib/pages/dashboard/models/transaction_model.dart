/// Modelo para uma transação do usuário.
class TransactionModel {
  final String id;
  final double amount;
  final String description;
  final DateTime createdAt;
  final String type;
  final String status;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.type,
    required this.status,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    // Handle Firestore Timestamp or ISO string
    DateTime date;
    if (map['created_at'] is Map && map['created_at'].containsKey('_seconds')) {
      date = DateTime.fromMillisecondsSinceEpoch(map['created_at']['_seconds'] * 1000);
    } else if (map['created_at'] is String) {
      date = DateTime.parse(map['created_at']);
    } else {
      date = DateTime.now();
    }

    return TransactionModel(
      id: map['id'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String? ?? 'Transação',
      createdAt: date,
      type: map['type'] as String? ?? 'other',
      status: map['status'] as String? ?? 'completed',
    );
  }
}
