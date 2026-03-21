/// --- Controller do Dashboard ---
/// Gerencia o estado reativo da UI da tela do Dashboard.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  
  // dependências
  final DashboardService _service = DashboardService();

  // estados globais
  bool isLoading = true; // estado de carregamento base (antes da UI)
  bool exibirValores = true; // visibilidade global do saldo (olhinho)
  DashboardData? data; // dados consolidados em tela
  String? errorMessage;

  /// Carrega/Busca os dados do dashboard
  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await _service.fetchUserDashboardData();
    } catch (e) {
      errorMessage = 'Erro ao carregar dados: $e';
    } finally {
      isLoading = false;
      notifyListeners(); 
    }
  }

  /// Alterna a visibilidade dos cifrões/saldos globalmente
  void toggleVisibility() {
    exibirValores = !exibirValores;
    notifyListeners();
  }
}
