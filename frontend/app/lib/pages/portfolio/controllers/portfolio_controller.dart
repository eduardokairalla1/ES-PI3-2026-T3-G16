/// --- Controller do portfólio ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';
import 'package:mesclainvest/pages/portfolio/services/portfolio_service.dart';

/// Eu gerencio o estado da tela de portfólio.
class PortfolioController extends ChangeNotifier {

  final PortfolioService _service = PortfolioService();

  PortfolioData? _data;
  bool _isLoading = false;
  bool _isObscured = false;

  // getters
  PortfolioData? get data => _data;
  bool get isLoading => _isLoading;
  bool get isObscured => _isObscured;


  /// Eu inicializo o controller e carrego os dados.
  PortfolioController() {
    loadPortfolio();
  }


  /// Eu busco os dados do portfólio a partir do serviço.
  Future<void> loadPortfolio() async {
    _isLoading = true;
    notifyListeners();

    try {
      _data = await _service.getPortfolioData();
    } catch (e) {
      // trata erro se necessário
      debugPrint('Erro ao carregar portfólio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Eu alterno a visibilidade de dados sensíveis (saldo).
  void toggleVisibility() {
    _isObscured = !_isObscured;
    notifyListeners();
  }

}
