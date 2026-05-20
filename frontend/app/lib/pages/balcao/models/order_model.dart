// --- Order model ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Shape of a P2P order as returned by onGetMyOrders and onCreateOrder.

// --- HELPERS ---

DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    final seconds = (value['_seconds'] as num?)?.toInt() ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

// --- MODEL ---

/// A single P2P order as returned by `onGetMyOrders` / `onCreateOrder`.
///
/// Carries the order's own data plus the denormalized startup name, logo URL
/// and token symbol so the "Minhas ordens" list can render without an extra
/// per-row lookup.
class OrderModel {
  final String orderId;
  final String startupId;
  final String startupName;
  final String? startupLogoUrl;
  final String tokenName;

  /// Order side: `'buy'` or `'sell'`.
  final String type;

  /// Lifecycle state: `'pending'`, `'completed'`, `'failed'` or `'cancelled'`.
  final String status;

  /// Total token quantity requested when the order was created.
  final int quantity;

  /// Tokens already matched against opposing offers. May be less than
  /// [quantity] for pending and cancelled orders (partial fills).
  final int filledQuantity;

  /// Author's limit price per token, in BRL.
  final double unitPrice;

  /// Weighted-average price actually paid/received across all fills; null
  /// while the order has no fills yet.
  final double? avgFillPrice;

  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const OrderModel({
    required this.orderId,
    required this.startupId,
    required this.startupName,
    required this.startupLogoUrl,
    required this.tokenName,
    required this.type,
    required this.status,
    required this.quantity,
    required this.filledQuantity,
    required this.unitPrice,
    required this.avgFillPrice,
    required this.createdAt,
    required this.completedAt,
    required this.cancelledAt,
  });

  /// Tokens still waiting to be matched ([quantity] minus [filledQuantity]).
  int get remaining => quantity - filledQuantity;

  /// Fill progress as a 0..1 fraction. Returns 0 when [quantity] is 0.
  double get progress => quantity == 0 ? 0 : filledQuantity / quantity;

  /// True when [type] is `'buy'`.
  bool get isBuy   => type == 'buy';

  /// True when [type] is `'sell'`.
  bool get isSell  => type == 'sell';

  /// True when [status] is `'pending'` (can still receive fills / be cancelled).
  bool get isOpen  => status == 'pending';

  /// Builds an [OrderModel] from the raw callable response payload.
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId:        map['orderId']        as String? ?? '',
      startupId:      map['startupId']      as String? ?? '',
      startupName:    map['startupName']    as String? ?? 'Startup',
      startupLogoUrl: map['startupLogoUrl'] as String?,
      tokenName:      map['tokenName']      as String? ?? '',
      type:           map['type']           as String? ?? 'buy',
      status:         map['status']         as String? ?? 'pending',
      quantity:       (map['quantity']        as num?)?.toInt()    ?? 0,
      filledQuantity: (map['filledQuantity']  as num?)?.toInt()    ?? 0,
      unitPrice:      (map['unitPrice']       as num?)?.toDouble() ?? 0,
      avgFillPrice:   (map['avgFillPrice']    as num?)?.toDouble(),
      createdAt:      _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      completedAt:    _parseTimestamp(map['completedAt']),
      cancelledAt:    _parseTimestamp(map['cancelledAt']),
    );
  }
}
