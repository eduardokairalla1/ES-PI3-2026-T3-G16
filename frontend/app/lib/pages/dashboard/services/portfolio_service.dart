/*
 * Serviço de portfolio do usuário.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';


/// Serviço responsável por integrar com a API de obtenção de carteira de ativos do usuário (custódia).
class PortfolioService {

  // Instância do Firebase Functions configurada.
  final _functions = FirebaseFunctions.instance;

  /// Busca os ativos em custódia (investimentos) atualmente detidos pelo investidor logado.
  ///
  /// Realiza a chamada remota da Cloud Function Callable `onGetPortfolio`.
  /// Retorna uma lista de [PortfolioItemModel] representando cada startup investida, a quantidade
  /// de tokens possuída e o preço de mercado atual.
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
