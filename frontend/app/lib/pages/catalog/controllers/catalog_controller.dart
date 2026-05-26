// --- Startup catalog controller ---
//
// Eduardo Kairalla - 24024241
// Controller for startup listing, stage filters and favorite toggles.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

// --- CODE ---

/// I manage startup catalog state and user favorite interactions.
class CatalogController extends ChangeNotifier {
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

  final CatalogService _service = CatalogService();
  final DashboardService _dashboardService = DashboardService();

  bool isLoading = true;
  List<StartupModel> startups = [];
  String? selectedStage; // null = all
  String? errorMessage;

  List<StartupModel> get visibleStartups {
    if (selectedStage != 'favorites') return startups;
    return startups
        .where((s) => AppState.instance.favoriteIds.contains(s.id))
        .toList();
  }

  /// I load startups for the current stage filter.
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final stage = selectedStage == 'favorites' ? null : selectedStage;
      final results = await Future.wait([
        _service.fetchStartups(stage: stage),
        _dashboardService.fetchUserDashboardData(),
      ]);
      startups = results[0] as List<StartupModel>;
      final dashboardData = results[1] as DashboardData;

      AppState.instance.setFinancialSummary(
        saldoDisponivel: dashboardData.saldoDisponivel,
        patrimonioTotal: dashboardData.patrimonioTotal,
      );
      AppState.instance.setFavoriteIds(dashboardData.favoriteIds.toSet());
    } catch (_) {
      errorMessage = 'Não foi possível carregar as startups. Tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// I apply a stage filter and reload.
  Future<void> filterByStage(String? stage) async {
    if (selectedStage == stage) return;
    selectedStage = stage;
    await load();
  }

  final Set<String> _togglingFavoriteIds = {};

  bool isTogglingFavorite(String startupId) {
    return _togglingFavoriteIds.contains(startupId);
  }

  /// Retorna se a startup correspondente ao ID informado está favoritada.
  bool isFavorite(String startupId) {
    return AppState.instance.favoriteIds.contains(startupId);
  }

  /// Adiciona ou remove uma startup dos favoritos do usuário.
  Future<void> toggleFavorite(String startupId) async {
    if (_togglingFavoriteIds.contains(startupId)) return;
    _togglingFavoriteIds.add(startupId);
    notifyListeners();

    final wasFav = AppState.instance.favoriteIds.contains(startupId);
    AppState.instance.setFavorite(startupId, !wasFav);

    try {
      final newStatus = await _dashboardService.toggleFavorite(startupId);
      AppState.instance.setFavorite(startupId, newStatus);
    } catch (_) {
      AppState.instance.setFavorite(startupId, wasFav);
    } finally {
      _togglingFavoriteIds.remove(startupId);
      notifyListeners();
    }
  }
}
