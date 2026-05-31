// --- Startup order book controller ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Manages state for the Balcão tab inside the startup detail page:
// the open offers and the form that submits new orders.

// --- IMPORTS ---
import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/balcao/models/order_book_model.dart';
import 'package:mesclainvest/pages/balcao/services/order_service.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';

// --- CONTROLLER ---

/// State holder for the balcão panel of a single startup.
///
/// Owns the live [OrderBookModel] for [startupId] and the small form state
/// that drives the buy/sell submit. After [load] the controller polls the
/// backend every 5 seconds via [refresh] so the book stays fresh while the
/// panel is visible; callers must invoke [dispose] to cancel the timer.
class StartupOrderBookController extends ChangeNotifier {
  bool _disposed = false;

  /// Creates a controller bound to [startupId]. Call [load] to fetch.
  StartupOrderBookController({required this.startupId});

  /// Firestore document id of the startup being traded.
  final String startupId;

  final OrderService     _service          = OrderService();
  final DashboardService _dashboardService = DashboardService();

  /// Current snapshot of the public book; starts as [OrderBookModel.empty].
  OrderBookModel book = OrderBookModel.empty();

  /// Tokens the current user holds in this startup. 0 when not invested.
  int ownedTokens = 0;

  /// True until the first [load] finishes (success or failure).
  bool isLoading = true;

  /// True while a background [refresh] is in flight.
  bool isRefreshing = false;

  /// User-facing error message from the last [load], or null on success.
  String? bookError;

  /// Currently selected order side in the form: `'buy'` or `'sell'`.
  String selectedType = 'buy';

  /// True while a [submitOrder] call is in flight.
  bool isSubmitting = false;

  /// User-facing validation/error message from the last [submitOrder],
  /// or null on success.
  String? submitError;

  /// Human-readable summary of the last successful submit
  /// (e.g. "Ordem fechada na hora (50 tokens).").
  String? lastResultMessage;

  Timer? _refreshTimer;

  /// Fetches the book for the first time and starts the 5s auto-refresh.
  Future<void> load() async {
    isLoading = true;
    bookError = null;
    notifyListeners();

    await Future.wait([
      _loadBook(),
      _loadOwnedTokens(),
    ]);

    isLoading = false;
    notifyListeners();

    // start auto-refresh every 5 seconds
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => refresh());
  }

  Future<void> _loadBook() async {
    try {
      book = await _service.getOrderBook(startupId);
    } catch (_) {
      bookError = 'Não foi possível carregar as ofertas. Tente novamente.';
    }
  }

  Future<void> _loadOwnedTokens() async {
    try {
      final data = await _dashboardService.fetchUserDashboardData();
      final match = data.investimentos.where((i) => i.startupId == startupId);
      ownedTokens = match.isEmpty ? 0 : match.first.tokenQuantity;
    } catch (_) {
      // best-effort — keep previous value
    }
  }

  /// Silent refresh used by the 5s timer and after a successful submit.
  /// On failure the previous [book] stays on screen so the user is not
  /// kicked back to an error state mid-trading.
  Future<void> refresh() async {
    if (isRefreshing) return;
    isRefreshing = true;
    notifyListeners();

    try {
      book = await _service.getOrderBook(startupId);
      bookError = null;
    } catch (_) {
      // keep the previous book on screen if the refresh fails
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  /// Switches the form between buy and sell. Clears any previous
  /// [submitError]. No-op when [type] already matches [selectedType].
  ///
  /// [type] must be `'buy'` or `'sell'`.
  void selectType(String type) {
    if (selectedType == type) return;
    selectedType = type;
    submitError = null;
    notifyListeners();
  }

  /// Submits a new order for the currently selected side and refreshes the
  /// book on success.
  ///
  /// The caller passes the already-parsed values from the form so the
  /// controller stays dumb about formatting. On success [lastResultMessage]
  /// is set to a human-readable summary; on failure [submitError] carries a
  /// localized message (insufficient balance, expired session, generic, …).
  ///
  /// [quantity]  must be > 0 (token count).
  /// [unitPrice] must be > 0 (BRL per token, the author's limit price).
  ///
  /// Returns true on success, false otherwise.
  Future<bool> submitOrder({
    required int quantity,
    required double unitPrice,
  }) async {
    submitError = null;
    lastResultMessage = null;

    if (quantity <= 0) {
      submitError = 'Quantidade deve ser maior que zero.';
      notifyListeners();
      return false;
    }
    if (unitPrice <= 0) {
      submitError = 'Preço deve ser maior que zero.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final outcome = await _service.createOrder(
        startupId: startupId,
        type:      selectedType,
        quantity:  quantity,
        unitPrice: unitPrice,
      );

      final filled    = (outcome['filled']    as num?)?.toInt() ?? 0;
      final remaining = (outcome['remaining'] as num?)?.toInt() ?? 0;

      if (filled == quantity) {
        lastResultMessage = 'Ordem fechada na hora ($filled tokens).';
      } else if (filled > 0) {
        lastResultMessage = 'Parcial: $filled tokens fechados, $remaining aguardando.';
      } else {
        lastResultMessage = 'Ordem aberta no balcão. Aguardando contraparte.';
      }

      // refresh the book and owned tokens to reflect the trade
      await Future.wait([refresh(), _loadOwnedTokens()]);
      notifyListeners();

      return true;
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'invalid-argument':
          final msg = (e.message ?? '').toLowerCase();
          if (msg.contains('balance')) {
            submitError = 'Saldo insuficiente para criar essa ordem.';
          } else if (msg.contains('tokens to sell') || msg.contains('available')) {
            submitError = 'Você não tem tokens suficientes para vender.';
          } else {
            submitError = e.message ?? 'Dados inválidos.';
          }
        case 'unauthenticated':
          submitError = 'Sessão expirada. Faça login novamente.';
        default:
          submitError = 'Não foi possível criar a ordem. Tente novamente.';
      }
      return false;
    } catch (_) {
      submitError = 'Erro inesperado. Tente novamente.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    super.dispose();
  }
}
