/*
 * Controller do Dashboard.
 * Centraliza estado de tela, chamadas de serviço, filtros e ações do usuário.
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
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
<<<<<<< HEAD
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';
=======
import 'package:mesclainvest/pages/dashboard/services/portfolio_service.dart';
import 'package:mesclainvest/pages/dashboard/services/token_history_service.dart';
>>>>>>> pr-65-davi
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

/*
 * CODE
 */

/// Gerencia o estado e a lógica de apresentação do Dashboard.
class DashboardController extends ChangeNotifier {
<<<<<<< HEAD
  // Dependências.
  final DashboardService _dashboardService = DashboardService();
  final CatalogService _catalogService = CatalogService();
=======

  // Dependências.
  final DashboardService    _dashboardService    = DashboardService();
  final TokenHistoryService _tokenHistoryService = TokenHistoryService();
  final CatalogService      _catalogService      = CatalogService();
  final PortfolioService    _portfolioService    = PortfolioService();
>>>>>>> pr-65-davi

  // Estado da UI.
  bool isLoading     = true;
  bool exibirValores = true;
  DashboardData? data;
  String? errorMessage;

<<<<<<< HEAD
  // Estado de favoritos (gerenciado separadamente do modelo).
  final Set<String> _favoriteIds = {};

  // Estado de Startups
  List<StartupModel> allStartups = [];
  String?
  selectedStartupFilter; // null = Todas, 'Favoritas' = Favoritas, ou stage (ex: 'new', 'operating')

  /// Carrega dados do dashboard e startups em paralelo.
=======
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
>>>>>>> pr-65-davi
  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _dashboardService.fetchUserDashboardData(),
        _catalogService.fetchStartups(),
<<<<<<< HEAD
      ]);

      data = results[0] as DashboardData;
      allStartups = results[1] as List<StartupModel>;

      // Sincroniza favoritos do backend.
      _favoriteIds
        ..clear()
        ..addAll(data!.favoriteIds);
=======
        _portfolioService.fetchPortfolio(),
      ]);

      data      = results[0] as DashboardData;
      startups  = results[1] as List<StartupModel>;
      portfolio = results[2] as List<PortfolioItemModel>;

      if (startups.isNotEmpty) {
        selectedStartup = startups.first;
        await _loadChart();
      }
>>>>>>> pr-65-davi
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados.\nVerifique sua conexão e tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
<<<<<<< HEAD
=======
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
>>>>>>> pr-65-davi
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
      return allStartups.where((s) => _favoriteIds.contains(s.id)).toList();
    }

    return allStartups.where((s) => s.stage == selectedStartupFilter).toList();
  }

  /// IDs de startups favoritas (leitura).
  Set<String> get favoriteIds => _favoriteIds;

  /// Verifica se uma startup é favorita.
  bool isFavorite(String startupId) {
    return _favoriteIds.contains(startupId);
  }

  /// Alterna o status de favorito e recarrega.
  Future<void> toggleFavorite(String startupId) async {
    if (data == null) return;

    // Atualização otimista
    final wasFav = _favoriteIds.contains(startupId);
    if (wasFav) {
      _favoriteIds.remove(startupId);
    } else {
      _favoriteIds.add(startupId);
    }
    notifyListeners();

    try {
      final newStatus = await _dashboardService.toggleFavorite(startupId);

      // Sincroniza com servidor (caso tenha divergido)
      if (newStatus) {
        _favoriteIds.add(startupId);
      } else {
        _favoriteIds.remove(startupId);
      }
      notifyListeners();
    } catch (_) {
      // Reverte em caso de erro
      if (wasFav) {
        _favoriteIds.add(startupId);
      } else {
        _favoriteIds.remove(startupId);
      }
      notifyListeners();
    }
  }

  /// Realiza um depósito e atualiza o estado.
  Future<void> deposit(double amount) async {
    if (data == null) return;

    try {
      final newBalance = await _dashboardService.deposit(amount);

      // O valor depositado é a diferença entre o novo saldo e o saldo anterior.
      final double depositedAmount = newBalance - data!.saldoDisponivel;

      // Atualiza o objeto data com o novo saldo e soma no patrimônio
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
      errorMessage = 'Erro ao realizar depósito: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Busca o histórico de transações recente.
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
