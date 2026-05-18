import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
import 'package:mesclainvest/pages/dashboard/services/portfolio_service.dart';
import 'package:mesclainvest/pages/dashboard/models/pending_order_model.dart';
import 'package:mesclainvest/pages/catalog/services/catalog_service.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';

class BalcaoController extends ChangeNotifier {

  final PortfolioService _portfolioService = PortfolioService();
  final CatalogService _catalogService = CatalogService();

  bool _disposed = false;
  bool isLoading = true;
  String? errorMessage;
  List<PortfolioItemModel> portfolio = [];
  List<PendingOrderModel> pendingOrders = [];
  List<StartupModel> startups = [];

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();

    try {
      final futures = await Future.wait([
        _portfolioService.fetchPortfolio(),
        _catalogService.fetchStartups()
      ]);
      final portfolioResult = futures[0] as ({List<PortfolioItemModel> holdings, List<PendingOrderModel> pendingOrders});
      portfolio = portfolioResult.holdings;
      pendingOrders = portfolioResult.pendingOrders;
      startups = futures[1] as List<StartupModel>;
    } catch (e) {
      errorMessage = 'Não foi possível carregar os dados.\nVerifique sua conexão e tente novamente.';
    } finally {
      isLoading = false;
      _safeNotify();
    }
  }
}
