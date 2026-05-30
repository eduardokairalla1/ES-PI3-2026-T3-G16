// --- Balcão hub controller ---
// Pedro Henrique Medeiros dos Reis - 24801656

// ignore_for_file: library_private_types_in_public_api
//
// Holds the state of the balcão hub:
//   - "Mercado": every startup available to trade, with the user's variation
//     since average purchase price (when owned)
//   - "Minhas ordens": every order this user has, across any startup
//   - wallet balance + search filter shared between both tabs

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/balcao/models/order_model.dart';
import 'package:mesclainvest/pages/balcao/services/order_service.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

// --- TYPES ---

enum BalcaoSort { nome, preco, variacao }

// --- CONTROLLER ---

/// State holder for the balcão hub.
///
/// Drives the two tabs of the hub page:
/// * "Mercado" — every startup available to trade, with per-startup variation
///   since the user's average purchase price (null when the user does not
///   own the startup).
/// * "Minhas ordens" — every order this user has, across any startup.
///
/// Also owns the shared header state: wallet balance and the search query
/// applied to the Mercado list. Cancel and edit requests for individual
/// orders are tracked per orderId so the UI can disable just the row being
/// acted upon.
class BalcaoController extends ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  final CatalogService _catalogService     = CatalogService();
  final OrderService _orderService         = OrderService();
  final DashboardService _dashboardService = DashboardService();

  // Mercado tab
  bool isLoadingStartups = true;
  String? startupsError;
  List<StartupModel> startups = [];

  // Minhas ordens tab
  bool isLoadingOrders = true;
  String? ordersError;
  List<OrderModel> orders = [];

  // Wallet + holdings (loaded from the dashboard payload so we get the
  // already-computed per-startup variation for free).
  double walletBalance = 0;
  bool isLoadingWallet = true;
  final Map<String, double> _variationByStartup = {};

  // Local search filter applied to the Mercado list.
  String _searchQuery = '';

  // Sort state for the Mercado list.
  BalcaoSort _sort    = BalcaoSort.nome;
  bool       _sortAsc = true;

  // In-flight tracking so the UI can disable just one row at a time.
  final Set<String> _cancelling = {};
  final Set<String> _editing    = {};

  /// Current search query (lower-cased, trimmed). Used by [filteredStartups].
  String get searchQuery => _searchQuery;

  /// Active sort criterion.
  BalcaoSort get sort => _sort;

  /// Whether the active sort is ascending.
  bool get sortAsc => _sortAsc;

  /// True while a cancel request for [orderId] is currently in flight.
  bool isCancelling(String orderId) => _cancelling.contains(orderId);

  /// True while an edit (cancel + recreate) for [orderId] is in flight.
  bool isEditing(String orderId) => _editing.contains(orderId);

  /// Variation (in percent) of the user's position on [startupId] since their
  /// average purchase price. Returns `null` if the user does not own the
  /// startup yet — the UI should render "—" in that case.
  double? variationFor(String startupId) => _variationByStartup[startupId];

  /// Startups filtered by [searchQuery] and sorted by the active criterion.
  /// Matches name or token symbol, case-insensitive.
  List<StartupModel> get filteredStartups {
    final q = _searchQuery;
    final list = q.isEmpty
        ? List<StartupModel>.from(startups)
        : startups
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.tokenName.toLowerCase().contains(q))
            .toList();

    list.sort((a, b) {
      int cmp;
      switch (_sort) {
        case BalcaoSort.preco:
          cmp = a.tokenPrice.compareTo(b.tokenPrice);
        case BalcaoSort.variacao:
          final va = _variationByStartup[a.id] ?? a.changePercent;
          final vb = _variationByStartup[b.id] ?? b.changePercent;
          if (va == null && vb == null) {
            cmp = 0;
          } else if (va == null) {
            return 1; // nulls always last regardless of direction
          } else if (vb == null) {
            return -1;
          } else {
            cmp = va.compareTo(vb);
          }
        case BalcaoSort.nome:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return _sortAsc ? cmp : -cmp;
    });

    return list;
  }

  /// Sets the active sort column. Tapping the same column toggles direction;
  /// tapping a different column resets to ascending.
  void setSort(BalcaoSort column) {
    if (_sort == column) {
      _sortAsc = !_sortAsc;
    } else {
      _sort    = column;
      _sortAsc = column != BalcaoSort.variacao;
    }
    notifyListeners();
  }

  /// Updates the search query and notifies listeners so the Mercado list
  /// re-renders with the new filter.
  void updateSearch(String query) {
    final next = query.trim().toLowerCase();
    if (next == _searchQuery) return;
    _searchQuery = next;
    notifyListeners();
  }

  /// Loads everything in parallel: startups, orders and wallet + holdings.
  Future<void> load({bool silent = false}) async {
    await Future.wait([
      loadStartups(silent: silent),
      loadMyOrders(silent: silent),
      loadWalletAndHoldings(silent: silent),
    ]);
  }

  /// Reloads the "Mercado" tab.
  Future<void> loadStartups({bool silent = false}) async {
    if (!silent) {
      isLoadingStartups = true;
      startupsError = null;
      notifyListeners();
    }

    try {
      startups = await _catalogService.fetchStartups();
      startupsError = null; // clear on success regardless of silent mode
    } catch (_) {
      if (!silent) startupsError = 'Não foi possível carregar as startups.';
    } finally {
      isLoadingStartups = false;
      notifyListeners();
    }
  }

  /// Reloads the "Minhas ordens" tab.
  Future<void> loadMyOrders({bool silent = false}) async {
    if (!silent) {
      isLoadingOrders = true;
      ordersError = null;
      notifyListeners();
    }

    try {
      orders = await _orderService.getMyOrders();
      ordersError = null; // clear on success regardless of silent mode
    } catch (_) {
      if (!silent) ordersError = 'Não foi possível carregar suas ordens.';
    } finally {
      isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Loads wallet balance and per-startup variation from the dashboard
  /// payload.
  Future<void> loadWalletAndHoldings({bool silent = false}) async {
    if (!silent) {
      isLoadingWallet = true;
      notifyListeners();
    }

    try {
      final data = await _dashboardService.fetchUserDashboardData();
      walletBalance = data.saldoDisponivel;
      _variationByStartup
        ..clear()
        ..addEntries(
          data.investimentos.map((i) => MapEntry(i.startupId, i.variation)),
        );
    } catch (_) {
      // best-effort: keep the previous values so the UI does not flash to 0
    } finally {
      isLoadingWallet = false;
      notifyListeners();
    }
  }

  /// Cancels [orderId] and refreshes the my-orders list on success.
  ///
  /// Returns a user-facing error message on failure, or null on success.
  /// Concurrent calls for the same orderId are deduplicated via the internal
  /// in-flight set.
  Future<String?> cancelOrder(String orderId) async {
    if (_cancelling.contains(orderId)) return null;
    _cancelling.add(orderId);
    notifyListeners();

    try {
      await _orderService.cancelOrder(orderId);
      await Future.wait([
        loadMyOrders(),
        loadWalletAndHoldings(),
      ]);
      return null;
    } on FirebaseFunctionsException catch (e) {
      return e.message ?? 'Não foi possível cancelar a ordem.';
    } catch (_) {
      return 'Erro inesperado ao cancelar a ordem.';
    } finally {
      _cancelling.remove(orderId);
      notifyListeners();
    }
  }

  /// Edits an existing order by cancelling the old one and creating a new
  /// one with [newQuantity] and [newUnitPrice]. The two operations are NOT
  /// atomic — if the create fails after the cancel succeeds, the user is
  /// left with no order; the error is surfaced so they can retry manually.
  ///
  /// Returns a user-facing error message on failure, or null on success.
  Future<String?> updateOrder({
    required OrderModel original,
    required int newQuantity,
    required double newUnitPrice,
  }) async {
    if (_editing.contains(original.orderId)) return null;
    _editing.add(original.orderId);
    notifyListeners();

    try {
      // 1. cancel the old order
      await _orderService.cancelOrder(original.orderId);
      // 2. create the new one with the updated price/quantity
      await _orderService.createOrder(
        startupId: original.startupId,
        type:      original.type,
        quantity:  newQuantity,
        unitPrice: newUnitPrice,
      );
      await Future.wait([
        loadMyOrders(),
        loadWalletAndHoldings(),
      ]);
      return null;
    } on FirebaseFunctionsException catch (e) {
      return e.message ?? 'Não foi possível editar a ordem.';
    } catch (_) {
      return 'Erro inesperado ao editar a ordem.';
    } finally {
      _editing.remove(original.orderId);
      notifyListeners();
    }
  }

  /// Performs a deposit and updates the wallet balance locally so the header
  /// reflects the new value without a full refetch. Rethrows on failure so
  /// the caller (e.g. [showDepositDialog]) can display the error.
  Future<void> deposit(double amount) async {
    final newBalance = await _dashboardService.deposit(amount);
    walletBalance = newBalance;
    notifyListeners();
  }
}
