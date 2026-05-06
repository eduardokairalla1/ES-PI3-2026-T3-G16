import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
import 'package:mesclainvest/pages/dashboard/services/portfolio_service.dart';

class BalcaoController extends ChangeNotifier {

  final PortfolioService _portfolioService = PortfolioService();

  bool isLoading = true;
  String? errorMessage;
  List<PortfolioItemModel> portfolio = [];

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      portfolio = await _portfolioService.fetchPortfolio();
    } catch (_) {
      errorMessage = 'Não foi possível carregar seus investimentos.\nVerifique sua conexão e tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
