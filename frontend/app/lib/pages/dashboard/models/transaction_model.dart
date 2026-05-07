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
    // Parse created_at handling all possible Firebase serialization formats:
    // - Map with '_seconds' (callable via web SDK)
    // - int (milliseconds since epoch)
    // - String (ISO 8601 format)
    // - Fallback: DateTime.now()
    DateTime date;
    try {
      final raw = map['created_at'];
      if (raw is Map && (raw.containsKey('_seconds') || raw.containsKey('seconds'))) {
        final seconds = (raw['_seconds'] ?? raw['seconds']) as int;
        date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else if (raw is int) {
        date = DateTime.fromMillisecondsSinceEpoch(raw);
      } else if (raw is String) {
        date = DateTime.parse(raw);
      } else {
        date = DateTime.now();
      }
    } catch (_) {
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
