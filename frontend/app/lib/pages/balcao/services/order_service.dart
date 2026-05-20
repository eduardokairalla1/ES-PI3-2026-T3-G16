// --- Order service ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Talks to the P2P (balcão) callables:
//   - onCreateOrder           → create + auto-match a buy/sell order
//   - onCancelOrder           → cancel an open order
//   - onGetStartupOrderBook   → public book for a startup
//   - onGetMyOrders           → my orders across every startup

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/balcao/models/order_book_model.dart';
import 'package:mesclainvest/pages/balcao/models/order_model.dart';

// --- SERVICE ---

/// Thin client over the P2P (balcão) Cloud Functions callables.
///
/// All methods talk to `FirebaseFunctions.instance` and either return the raw
/// callable payload (for [createOrder]) or map it into a domain model.
class OrderService {
  final _functions = FirebaseFunctions.instance;

  /// Create a new P2P order. The backend will try to cross it against the
  /// opposing side of the book automatically. Returns the outcome:
  /// orderId, status, filled, remaining, totalAmount, avgPrice, completedAt.
  Future<Map<String, dynamic>> createOrder({
    required String startupId,
    required String type, // 'buy' | 'sell'
    required int quantity,
    required double unitPrice,
  }) async {
    final result = await _functions
        .httpsCallable('onCreateOrder')
        .call<Map<String, dynamic>>({
          'startupId': startupId,
          'type':      type,
          'quantity':  quantity,
          'unitPrice': unitPrice,
        });

    return Map<String, dynamic>.from(result.data as Map);
  }

  /// Cancel one of the caller's own pending orders.
  Future<void> cancelOrder(String orderId) async {
    await _functions
        .httpsCallable('onCancelOrder')
        .call<Map<String, dynamic>>({'orderId': orderId});
  }

  /// Fetch the order book of a startup (aggregated by price level).
  Future<OrderBookModel> getOrderBook(String startupId, {int depth = 20}) async {
    final result = await _functions
        .httpsCallable('onGetStartupOrderBook')
        .call<Map<String, dynamic>>({
          'startupId': startupId,
          'depth':     depth,
        });

    return OrderBookModel.fromMap(Map<String, dynamic>.from(result.data as Map));
  }

  /// Fetch every order the caller has (any status, any startup), newest first.
  Future<List<OrderModel>> getMyOrders() async {
    final result = await _functions
        .httpsCallable('onGetMyOrders')
        .call<Map<String, dynamic>>({});

    final raw = (result.data as Map)['orders'] as List<dynamic>? ?? [];
    return raw
        .map((o) => OrderModel.fromMap(Map<String, dynamic>.from(o as Map)))
        .toList();
  }
}
