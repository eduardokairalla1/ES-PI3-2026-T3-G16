/// Gerencia o estado e lógica da UI do Dashboard.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
import 'package:mesclainvest/pages/dashboard/services/dashboard_service.dart';
import 'package:mesclainvest/pages/dashboard/services/portfolio_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

class DashboardController extends ChangeNotifier {

  final DashboardService  _dashboardService  = DashboardService();
  final CatalogService    _catalogService    = CatalogService();
  final PortfolioService  _portfolioService  = PortfolioService();

  bool isLoading     = true;
  bool exibirValores = true;
  DashboardData? data;
  String? errorMessage;

  List<PortfolioItemModel> portfolio = [];
  List<StartupModel>       startups  = [];

  Future<void> loadDashboard() async {
    isLoading    = true;
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
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados.\nVerifique sua conexão e tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleVisibility() {
    exibirValores = !exibirValores;
    notifyListeners();
  }
}
