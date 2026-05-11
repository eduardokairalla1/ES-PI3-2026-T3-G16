/*
 * Controller do Dashboard.
 * Centraliza estado de tela, chamadas de servico, filtros e acoes do usuario.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */
library;

/*
 * IMPORTS
 */
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
import 'package:mesclainvest/pages/dashboard/models/price_snapshot_model.dart';
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/dashboard/services/portfolio_service.dart';
import 'package:mesclainvest/pages/dashboard/services/token_history_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

/*
 * CODE
 */

/// Gerencia o estado e a logica de apresentacao do Dashboard.
class DashboardController extends ChangeNotifier {
  // Dependencies.
  final DashboardService _dashboardService = DashboardService();
  final CatalogService _catalogService = CatalogService();
  final TokenHistoryService _tokenHistoryService = TokenHistoryService();
  final PortfolioService _portfolioService = PortfolioService();

  // UI state.
  bool isLoading = true;
  bool exibirValores = true;
  DashboardData? data;
  String? errorMessage;

  // Favorites.
  final Set<String> _favoriteIds = {};

  // Startup & portfolio state.
  List<StartupModel> startups = [];
  StartupModel? selectedStartup;
  String? selectedStartupFilter;

  List<PortfolioItemModel> portfolio = [];

  // Chart state.
  bool isLoadingChart = false;
  String selectedPeriod = 'weekly';
  TokenHistoryModel? tokenHistory;
  String? chartErrorMessage;

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

      data = results[0] as DashboardData;
      startups = results[1] as List<StartupModel>;
      portfolio = results[2] as List<PortfolioItemModel>;

      _favoriteIds
        ..clear()
        ..addAll(data!.favoriteIds);

      if (startups.isNotEmpty) {
        selectedStartup = startups.first;
        await _loadChart();
      }
    } catch (e) {
      errorMessage =
          'Nao foi possivel carregar os dados.\nVerifique sua conexao e tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectStartup(StartupModel startup) async {
    selectedStartup = startup;
    notifyListeners();
    await _loadChart();
  }

  Future<void> selectPeriod(String period) async {
    selectedPeriod = period;
    notifyListeners();
    await _loadChart();
  }

  Future<void> _loadChart() async {
    if (selectedStartup == null) return;
    isLoadingChart = true;
    chartErrorMessage = null;
    notifyListeners();

    try {
      tokenHistory = await _tokenHistoryService.fetchHistory(
        selectedStartup!.id,
        selectedPeriod,
      );
    } catch (_) {
      tokenHistory = null;
      chartErrorMessage =
          'Nao foi possivel carregar o historico. Tente novamente.';
    } finally {
      isLoadingChart = false;
      notifyListeners();
    }
  }

  void toggleVisibility() {
    exibirValores = !exibirValores;
    notifyListeners();
  }

  void filterStartups(String? filter) {
    if (selectedStartupFilter == filter) return;
    selectedStartupFilter = filter;
    notifyListeners();
  }

  List<StartupModel> get filteredStartups {
    if (selectedStartupFilter == null) return startups;

    if (selectedStartupFilter == 'Favoritas') {
      return startups.where((s) => _favoriteIds.contains(s.id)).toList();
    }

    return startups.where((s) => s.stage == selectedStartupFilter).toList();
  }

  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String startupId) => _favoriteIds.contains(startupId);

  Future<void> toggleFavorite(String startupId) async {
    if (data == null) return;

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

  Future<void> deposit(double amount) async {
    if (data == null) return;

    try {
      final newBalance = await _dashboardService.deposit(amount);
      final double depositedAmount = newBalance - data!.saldoDisponivel;
      data = DashboardData(
        nomeUsuario: data!.nomeUsuario,
        patrimonioTotal: data!.patrimonioTotal + depositedAmount,
        saldoDisponivel: newBalance,
        rendimentoDiarioValor: data!.rendimentoDiarioValor,
        rendimentoDiarioPorcentagem: data!.rendimentoDiarioPorcentagem,
        totalStartupsMercado: data!.totalStartupsMercado,
        rentabilidadeMediaMercado: data!.rentabilidadeMediaMercado,
        totalInvestidoresMercado: data!.totalInvestidoresMercado,
        investimentos: data!.investimentos,
        favoriteIds: data!.favoriteIds,
      );
      notifyListeners();
    } catch (e) {
      errorMessage = 'Erro ao realizar deposito: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final list = await _dashboardService.getTransactions();
      return list.map((m) => TransactionModel.fromMap(m)).toList();
    } catch (e) {
      errorMessage = 'Erro ao buscar extrato: $e';
      notifyListeners();
      return [];
    }
  }
}
