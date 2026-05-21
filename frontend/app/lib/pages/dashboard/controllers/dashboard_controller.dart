/// Gerencia o estado e lógica da UI do Dashboard.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
import 'package:mesclainvest/pages/dashboard/models/price_snapshot_model.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/dashboard/services/portfolio_service.dart';
import 'package:mesclainvest/pages/dashboard/services/token_history_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

class DashboardController extends ChangeNotifier {

  // Dependências.
  final DashboardService    _dashboardService    = DashboardService();
  final TokenHistoryService _tokenHistoryService = TokenHistoryService();
  final CatalogService      _catalogService      = CatalogService();
  final PortfolioService    _portfolioService    = PortfolioService();

  // Estado da UI.
  bool isLoading     = true;
  bool exibirValores = true;
  DashboardData? data;
  String? errorMessage;

  // Portfolio do usuário.
  List<PortfolioItemModel> portfolio = [];

  // Estado do card de valorização (mantido para compatibilidade).
  bool             isLoadingChart   = false;
  String           selectedPeriod   = 'weekly';
  TokenHistoryModel? tokenHistory;
  String?          chartErrorMessage;
  List<StartupModel> startups       = [];
  StartupModel?    selectedStartup;

  /// Carrega dados do dashboard e a lista de startups.
  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _dashboardService.fetchUserDashboardData(),
        _catalogService.fetchStartups(),
        _portfolioService.fetchPortfolio(),
      ]);

      data      = results[0] as DashboardData;
      startups  = results[1] as List<StartupModel>;
      portfolio = results[2] as List<PortfolioItemModel>;

      if (startups.isNotEmpty) {
        selectedStartup = startups.first;
        await _loadChart();
      }
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados.\nVerifique sua conexão e tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Troca a startup selecionada e recarrega o gráfico.
  Future<void> selectStartup(StartupModel startup) async {
    selectedStartup = startup;
    notifyListeners();
    await _loadChart();
  }

  /// Troca o período e recarrega o gráfico.
  Future<void> selectPeriod(String period) async {
    selectedPeriod = period;
    notifyListeners();
    await _loadChart();
  }

  Future<void> _loadChart() async {
    if (selectedStartup == null) return;
    isLoadingChart   = true;
    chartErrorMessage = null;
    notifyListeners();

    try {
      tokenHistory = await _tokenHistoryService.fetchHistory(
        selectedStartup!.id,
        selectedPeriod,
      );
    } catch (_) {
      tokenHistory      = null;
      chartErrorMessage = 'Não foi possível carregar o histórico. Tente novamente.';
    } finally {
      isLoadingChart = false;
      notifyListeners();
    }
  }

  /// Alterna a visibilidade dos saldos.
  void toggleVisibility() {
    exibirValores = !exibirValores;
    notifyListeners();
  }
}
