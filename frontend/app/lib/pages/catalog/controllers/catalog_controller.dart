// Eduardo Kairalla - 24024241

// Controller for the startup catalog page.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

// --- CONTROLLER ---

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

  final Set<String> _favoriteIds = {};

  /// I load startups for the current stage filter.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _service.fetchStartups(stage: selectedStage),
        _dashboardService.fetchUserDashboardData(),
      ]);
      startups = results[0] as List<StartupModel>;
      final dashboardData = results[1] as DashboardData;

      _favoriteIds
        ..clear()
        ..addAll(dashboardData.favoriteIds);
    } catch (_) {
      if (!silent) errorMessage = 'Não foi possível carregar as startups. Tente novamente.';
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

  /// Retorna se a startup correspondente ao ID informado está favoritada.
  bool isFavorite(String startupId) {
    return _favoriteIds.contains(startupId);
  }

  /// Adiciona ou remove uma startup dos favoritos do usuário.
  Future<void> toggleFavorite(String startupId) async {
    final wasFav = _favoriteIds.contains(startupId);
    if (wasFav) {
      _favoriteIds.remove(startupId);
    } else {
      _favoriteIds.add(startupId);
    }
    notifyListeners();

    try {
      final newStatus = await _dashboardService.toggleFavorite(startupId);
      if (newStatus) {
        _favoriteIds.add(startupId);
      } else {
        _favoriteIds.remove(startupId);
      }
      notifyListeners();
    } catch (_) {
      if (wasFav) {
        _favoriteIds.add(startupId);
      } else {
        _favoriteIds.remove(startupId);
      }
      notifyListeners();
    }
  }
}
