/// Serviço de portfolio do usuário.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
import 'package:mesclainvest/pages/dashboard/models/pending_order_model.dart';


class PortfolioService {

  final _functions = FirebaseFunctions.instance;

  Future<({List<PortfolioItemModel> holdings, List<PendingOrderModel> pendingOrders})> fetchPortfolio() async {
    final result = await _functions
        .httpsCallable('onGetPortfolio')
        .call<Map<String, dynamic>>();

    final data = result.data as Map;

    final rawHoldings = data['holdings'] as List<dynamic>? ?? [];
    final holdings = rawHoldings
        .map((h) => PortfolioItemModel.fromMap(Map<String, dynamic>.from(h as Map)))
        .toList();

    final rawPending = data['pendingOrders'] as List<dynamic>? ?? [];
    final pendingOrders = rawPending
        .map((p) => PendingOrderModel.fromMap(Map<String, dynamic>.from(p as Map)))
        .toList();

    return (holdings: holdings, pendingOrders: pendingOrders);
  }
}
