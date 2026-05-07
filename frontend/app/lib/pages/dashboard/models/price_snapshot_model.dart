/// Modelo de snapshot de preço de token.

class PriceSnapshotModel {
  final double   price;
  final DateTime recordedAt;

  const PriceSnapshotModel({required this.price, required this.recordedAt});

  factory PriceSnapshotModel.fromMap(Map<String, dynamic> map) {
    return PriceSnapshotModel(
      price:      (map['price'] as num).toDouble(),
      recordedAt: _parseTimestamp(map['recordedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final seconds = (value['_seconds'] as num?)?.toInt() ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
    return null;
  }
}


class TokenHistoryModel {
  final double                   currentPrice;
  final double?                  purchasePrice;
  final int                      tokenQuantity;
  final double                   totalValue;
  final List<PriceSnapshotModel> snapshots;

  const TokenHistoryModel({
    required this.currentPrice,
    required this.purchasePrice,
    required this.tokenQuantity,
    required this.totalValue,
    required this.snapshots,
  });

  factory TokenHistoryModel.fromMap(Map<String, dynamic> map) {
    final raw = (map['snapshots'] as List<dynamic>?) ?? [];
    return TokenHistoryModel(
      currentPrice:  (map['currentPrice']  as num).toDouble(),
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble(),
      tokenQuantity: (map['tokenQuantity'] as num?)?.toInt()    ?? 0,
      totalValue:    (map['totalValue']    as num?)?.toDouble() ?? 0.0,
      snapshots: raw
          .map((s) => PriceSnapshotModel.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList(),
    );
  }

  bool get hasInvestment => purchasePrice != null && snapshots.isNotEmpty;

  /// Preço no início do período exibido (primeiro snapshot da janela).
  double get periodStartPrice =>
      snapshots.isNotEmpty ? snapshots.first.price : currentPrice;

  /// Variação percentual dentro do período selecionado.
  double get changePercent {
    if (periodStartPrice == 0) return 0;
    return ((currentPrice - periodStartPrice) / periodStartPrice) * 100;
  }
}
