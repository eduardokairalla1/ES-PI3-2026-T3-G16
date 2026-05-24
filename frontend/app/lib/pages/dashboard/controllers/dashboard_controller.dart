/*
 * Gerencia o estado e lógica da UI do Dashboard.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

/// Controlador que gerencia o estado e a lógica de negócios da UI do Dashboard.
/// Estende [ChangeNotifier] para notificar a View sobre atualizações de dados.
class DashboardController extends ChangeNotifier {
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

  // Instâncias dos serviços utilizados para buscar informações da API
  final DashboardService  _dashboardService  = DashboardService();
  final CatalogService    _catalogService    = CatalogService();

  // Estados fundamentais de exibição
  bool isLoading     = true; // Flag indicando se há requisições assíncronas em andamento
  bool exibirValores = true; // Controla a visibilidade dos valores monetários (modo de privacidade)
  DashboardData? data;       // Dados consolidados do painel do investidor
  String? errorMessage;      // Mensagem de erro caso a requisição falhe

  List<StartupModel>       startups  = [];

  // Estado de favoritos (gerenciado localmente para resposta imediata/otimista).
  final Set<String> _favoriteIds = {};

  // Coleção completa de startups e filtro selecionado para exibição
  List<StartupModel> allStartups = [];
  String? selectedStartupFilter; // null = Todas, 'Favoritas' = Favoritas, ou estágio (ex: 'new', 'operating')

  /// Carrega os dados consolidados do dashboard do usuário e a lista de startups em paralelo.
  /// Atualiza os estados de carregamento e notifica os ouvintes da View.
  Future<void> loadDashboard() async {
    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Dispara as consultas da API em paralelo para diminuir a latência do app
      final results = await Future.wait([
        _dashboardService.fetchUserDashboardData(),
        _catalogService.fetchStartups(),
      ]);

      data        = results[0] as DashboardData;
      allStartups = results[1] as List<StartupModel>;

      // Sincroniza o conjunto local de favoritos
      _favoriteIds
        ..clear()
        ..addAll(data!.favoriteIds);
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados.\nVerifique sua conexão e tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Alterna a visibilidade dos valores monetários na tela (olho aberto/fechado).
  void toggleVisibility() {
    exibirValores = !exibirValores;
    notifyListeners();
  }

  /// Alterna o filtro ativo de exibição de startups (ex: Favoritas, Novas, Operação).
  void filterStartups(String? filter) {
    if (selectedStartupFilter == filter) return;
    selectedStartupFilter = filter;
    notifyListeners();
  }

  /// Retorna a lista de startups pós-aplicação do filtro selecionado (`selectedStartupFilter`).
  List<StartupModel> get filteredStartups {
    if (selectedStartupFilter == null) return allStartups;

    if (selectedStartupFilter == 'Favoritas') {
      return allStartups.where((s) => _favoriteIds.contains(s.id)).toList();
    }

    return allStartups.where((s) => s.stage == selectedStartupFilter).toList();
  }

  /// IDs de todas as startups marcadas como favoritas pelo usuário.
  Set<String> get favoriteIds => _favoriteIds;

  /// Retorna se a startup correspondente ao ID informado está favoritada.
  bool isFavorite(String startupId) {
    return _favoriteIds.contains(startupId);
  }

  /// Adiciona ou remove uma startup dos favoritos do usuário.
  /// Utiliza uma **atualização otimista** na interface antes do retorno da API para melhor responsividade.
  Future<void> toggleFavorite(String startupId) async {
    if (data == null) return;

    // 1. Atualização otimista imediata na UI
    final wasFav = _favoriteIds.contains(startupId);
    if (wasFav) {
      _favoriteIds.remove(startupId);
    } else {
      _favoriteIds.add(startupId);
    }
    notifyListeners();

    try {
      // 2. Envia a requisição para o servidor backend
      final newStatus = await _dashboardService.toggleFavorite(startupId);

      // Sincroniza o conjunto local com o status retornado para certificar consistência
      if (newStatus) {
        _favoriteIds.add(startupId);
      } else {
        _favoriteIds.remove(startupId);
      }
      notifyListeners();
    } catch (_) {
      // 3. Reverte o estado local em caso de erro na requisição
      if (wasFav) {
        _favoriteIds.add(startupId);
      } else {
        _favoriteIds.remove(startupId);
      }
      notifyListeners();
    }
  }

  /// Executa uma simulação de depósito virtual na conta do investidor.
  /// Atualiza o saldo local e ajusta o patrimônio total de forma proporcional.
  Future<void> deposit(double amount) async {
    if (data == null) return;

    try {
      // Envia requisição para incrementar o saldo do usuário
      final newBalance = await _dashboardService.deposit(amount);

      // Calcula a variação exata para atualizar o patrimônio proporcionalmente
      final double depositedAmount = newBalance - data!.saldoDisponivel;

      // Imuta e atualiza a instância dos dados locais do dashboard
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

  /// Retorna o histórico consolidado recente de movimentações (extrato unificado) do investidor.
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

  /// Busca o histórico de evolução patrimonial real do usuário para o período especificado.
  Future<List<Map<String, dynamic>>> fetchPatrimonyHistory(String period) async {
    return _dashboardService.fetchPatrimonyHistory(period);
  }
}
