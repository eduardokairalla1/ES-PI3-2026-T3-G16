// --- Order book model ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Shape of the open offers returned by onGetStartupOrderBook. We get one
// OpenOrderEntry per individual order (not aggregated), plus the last
// completed trade and the current bonding-curve price (used as the market
// reference for variance display).

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

// --- ENTRY ---

/// One open order in the public book — never aggregated by price.
///
/// Each entry maps 1:1 to a Firestore order document; the matching engine and
/// the order book screen both consume the same shape.
class OpenOrderEntry {
  final String orderId;

  /// Firebase Auth UID of the order's author.
  final String uid;

  /// Limit price per token, in BRL.
  final double price;

  /// Total tokens of the order at creation time.
  final int quantity;

  /// Unfilled portion still resting on the book ([quantity] minus filled).
  final int remaining;

  final DateTime createdAt;

  const OpenOrderEntry({
    required this.orderId,
    required this.uid,
    required this.price,
    required this.quantity,
    required this.remaining,
    required this.createdAt,
  });

  /// Builds an [OpenOrderEntry] from a single entry of the callable response.
  factory OpenOrderEntry.fromMap(Map<String, dynamic> map) {
    return OpenOrderEntry(
      orderId:   map['orderId']   as String? ?? '',
      uid:       map['uid']       as String? ?? '',
      price:     (map['price']     as num?)?.toDouble() ?? 0,
      quantity:  (map['quantity']  as num?)?.toInt()    ?? 0,
      remaining: (map['remaining'] as num?)?.toInt()    ?? 0,
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
    );
  }
}

// --- BOOK ---

/// Public order book of a startup as returned by `onGetStartupOrderBook`.
///
/// Holds both sides of the book (best price first) and the price references
/// used to render the variance pill on each offer card.
class OrderBookModel {
  /// Open buy offers, best price first (highest first).
  final List<OpenOrderEntry> buyOrders;

  /// Open sell offers, best price first (lowest first).
  final List<OpenOrderEntry> sellOrders;

  /// Average price of the most recent completed trade; null if no trade yet.
  final double? lastTradePrice;

  /// Timestamp of the most recent completed trade; null if no trade yet.
  final DateTime? lastTradeAt;

  /// Current bonding-curve price — used as the market reference so each
  /// offer card can render its `±%` variance.
  final double currentMarketPrice;

  const OrderBookModel({
    required this.buyOrders,
    required this.sellOrders,
    required this.lastTradePrice,
    required this.lastTradeAt,
    required this.currentMarketPrice,
  });

  /// Top-of-book buy price, or null when the buy side is empty.
  double? get bestBuyPrice  => buyOrders.isEmpty  ? null : buyOrders.first.price;

  /// Top-of-book sell price, or null when the sell side is empty.
  double? get bestSellPrice => sellOrders.isEmpty ? null : sellOrders.first.price;

  /// True when both sides of the book are empty.
  bool get isEmpty => buyOrders.isEmpty && sellOrders.isEmpty;

  /// Builds an [OrderBookModel] from the raw callable response payload.
  factory OrderBookModel.fromMap(Map<String, dynamic> map) {
    final rawBuys  = (map['buyOrders']  as List<dynamic>?) ?? [];
    final rawSells = (map['sellOrders'] as List<dynamic>?) ?? [];

    return OrderBookModel(
      buyOrders: rawBuys
          .map((b) => OpenOrderEntry.fromMap(Map<String, dynamic>.from(b as Map)))
          .toList(),
      sellOrders: rawSells
          .map((s) => OpenOrderEntry.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList(),
      lastTradePrice:     (map['lastTradePrice']     as num?)?.toDouble(),
      lastTradeAt:        _parseTimestamp(map['lastTradeAt']),
      currentMarketPrice: (map['currentMarketPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Empty book used as the initial state of the controller before the first
  /// fetch returns.
  factory OrderBookModel.empty() {
    return const OrderBookModel(
      buyOrders:          [],
      sellOrders:         [],
      lastTradePrice:     null,
      lastTradeAt:        null,
      currentMarketPrice: 0,
    );
  }
}
