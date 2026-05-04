/// Gerencia o estado e lógica da UI do Dashboard.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

class DashboardController extends ChangeNotifier {
  
  // Dependências.
  final DashboardService _dashboardService = DashboardService();
  final CatalogService _catalogService = CatalogService();

  // Estado da UI.
  bool isLoading = true; // Controle de carregamento.
  bool exibirValores = true; // Visibilidade dos saldos.
  DashboardData? data; // Dados consolidados.
  String? errorMessage;

  // Estado de Startups
  List<StartupModel> allStartups = [];
  String? selectedStartupFilter; // null = Todas, 'Favoritas' = Favoritas, ou stage (ex: 'new', 'operating')

  /// Carrega dados do dashboard e startups em paralelo.
  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _dashboardService.fetchUserDashboardData(),
        _catalogService.fetchStartups(),
      ]);

      data = results[0] as DashboardData;
      allStartups = results[1] as List<StartupModel>;
    } catch (e) {
      errorMessage = 'Erro ao carregar dados: $e';
    } finally {
      isLoading = false;
      notifyListeners(); 
    }
  }

  /// Alterna a visibilidade dos saldos.
  void toggleVisibility() {
    exibirValores = !exibirValores;
    notifyListeners();
  }

  /// Alterna o filtro ativo de startups.
  void filterStartups(String? filter) {
    if (selectedStartupFilter == filter) return;
    selectedStartupFilter = filter;
    notifyListeners();
  }

  /// Retorna as startups filtradas.
  List<StartupModel> get filteredStartups {
    if (selectedStartupFilter == null) return allStartups;
    
    if (selectedStartupFilter == 'Favoritas') {
      final favoriteIds = data?.favoriteIds ?? [];
      return allStartups.where((s) => favoriteIds.contains(s.id)).toList();
    }
    
    return allStartups.where((s) => s.stage == selectedStartupFilter).toList();
  }

  /// Verifica se uma startup é favorita.
  bool isFavorite(String startupId) {
    return data?.favoriteIds.contains(startupId) ?? false;
  }

  /// Alterna o status de favorito e recarrega.
  Future<void> toggleFavorite(String startupId) async {
    if (data == null) return;
    
    // Atualização otimista
    final isFav = isFavorite(startupId);
    if (isFav) {
      data!.favoriteIds.remove(startupId);
    } else {
      data!.favoriteIds.add(startupId);
    }
    notifyListeners();

    try {
      final newStatus = await _dashboardService.toggleFavorite(startupId);
      
      // Sincroniza com servidor (caso tenha divergido)
      if (newStatus) {
        if (!data!.favoriteIds.contains(startupId)) data!.favoriteIds.add(startupId);
      } else {
        data!.favoriteIds.remove(startupId);
      }
      notifyListeners();
    } catch (_) {
      // Reverte em caso de erro
      if (isFav) {
        data!.favoriteIds.add(startupId);
      } else {
        data!.favoriteIds.remove(startupId);
      }
      notifyListeners();
    }
  }
}
