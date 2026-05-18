// --- Startup service ---
//
// Eduardo Kairalla - 24024241

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

// --- SERVICE ---

/// I handle all Firebase Cloud Function calls related to startups.
class StartupService {
  final _functions = FirebaseFunctions.instance;

  /// I fetch a single startup by ID.
  Future<StartupModel> fetchStartup(String id) async {
    final result = await _functions
        .httpsCallable('onGetStartup')
        .call<Map<String, dynamic>>({'id': id});

    return StartupModel.fromMap(Map<String, dynamic>.from(result.data as Map));
  }

  /// I fetch the public questions for a startup.
  Future<List<QuestionModel>> fetchQuestions(String startupId) async {
    final result = await _functions
        .httpsCallable('onGetQuestions')
        .call<Map<String, dynamic>>({'startupId': startupId});

    final raw = (result.data as Map)['questions'] as List<dynamic>? ?? [];
    return raw
        .map((q) => QuestionModel.fromMap(Map<String, dynamic>.from(q as Map)))
        .toList();
  }

  /// I send a question to a startup.
  Future<void> sendQuestion(
    String startupId,
    String text,
    bool isPrivate,
  ) async {
    await _functions.httpsCallable('onSendQuestion').call<Map<String, dynamic>>(
      {'isPrivate': isPrivate, 'startupId': startupId, 'text': text},
    );
  }

  /// I create a buy or sell order for a startup and return the order ID.
  Future<String> createOrder(String startupId, int quantity, double price, String type) async {
    final result = await _functions
        .httpsCallable('onCreateOrder')
        .call<Map<String, dynamic>>({
          'startupId': startupId,
          'quantity':  quantity,
          'price':     price,
          'type':      type,
        });

    return (result.data as Map)['orderId'] as String;
  }

  /// I update a pending order and return the new order ID.
  Future<String> updateOrder(String orderId, int quantity, double price, String type) async {
    final result = await _functions
        .httpsCallable('onUpdateOrder')
        .call<Map<String, dynamic>>({
          'orderId': orderId,
          'quantity': quantity,
          'price': price,
          'type': type,
        });

    return (result.data as Map)['orderId'] as String;
  }

  /// I fetch the order book for a startup.
  Future<List<Map<String, dynamic>>> fetchOrderBook(String startupId) async {
    final result = await _functions
        .httpsCallable('onGetOrderBook')
        .call<Map<String, dynamic>>({'startupId': startupId});

    final raw = (result.data as Map)['orders'] as List<dynamic>? ?? [];
    return raw.map((o) => Map<String, dynamic>.from(o as Map)).toList();
  }
}

