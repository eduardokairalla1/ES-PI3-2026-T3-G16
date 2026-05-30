// Eduardo Kairalla - 24024241

// Controller for the startup catalog page.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

// --- CONTROLLER ---

/// I manage state and logic for the startup catalog page.
class CatalogController extends ChangeNotifier {
  bool _disposed = false;

  /// I dispose this controller and prevent further listener notifications.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// I notify listeners only when the controller has not been disposed.
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  final CatalogService _service = CatalogService();
  final DashboardService _dashboardService = DashboardService();

  bool isLoading = true;
  List<StartupModel> _allStartups = [];
  String? selectedStage; // null = all
  String? errorMessage;
  String _searchQuery = '';

  /// I return the filtered list of startups matching the current search query.
  List<StartupModel> get startups {
    if (_searchQuery.isEmpty) return _allStartups;
    final q = _searchQuery.toLowerCase();
    return _allStartups.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

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
      _allStartups = results[0] as List<StartupModel>;
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

  /// I filter startups by name using the provided search query.
  void filterByName(String query) {
    _searchQuery = query.trim();
    notifyListeners();
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
