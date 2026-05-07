/// Serviço de portfolio do usuário.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';


class PortfolioService {

  final _functions = FirebaseFunctions.instance;

  Future<List<PortfolioItemModel>> fetchPortfolio() async {
    final result = await _functions
        .httpsCallable('onGetPortfolio')
        .call<Map<String, dynamic>>();

    final raw = (result.data as Map)['holdings'] as List<dynamic>? ?? [];
    return raw
        .map((h) => PortfolioItemModel.fromMap(Map<String, dynamic>.from(h as Map)))
        .toList();
  }
}
