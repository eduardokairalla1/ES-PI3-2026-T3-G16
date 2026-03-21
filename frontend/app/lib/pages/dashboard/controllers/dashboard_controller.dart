/// Gerencia o estado e lógica da UI do Dashboard.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  
  // Dependências.
  final DashboardService _service = DashboardService();

  // Estado da UI.
  bool isLoading = true; // Controle de carregamento.
  bool exibirValores = true; // Visibilidade dos saldos.
  DashboardData? data; // Dados consolidados.
  String? errorMessage;

  /// Carrega dados do dashboard.
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

  /// Alterna a visibilidade dos saldos.
  void toggleVisibility() {
    exibirValores = !exibirValores;
    notifyListeners();
  }
}
