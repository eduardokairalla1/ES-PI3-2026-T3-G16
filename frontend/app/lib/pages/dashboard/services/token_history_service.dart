/*
 * Serviço de histórico de preços de tokens.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/dashboard/models/price_snapshot_model.dart';


/// Serviço que gerencia a comunicação com as APIs para obtenção do histórico de cotações dos tokens.
class TokenHistoryService {

  // Instância do Firebase Cloud Functions para chamadas HTTP Callable.
  final _functions = FirebaseFunctions.instance;

  /// Busca o histórico de preços dos tokens de uma startup específica correspondente ao ID informado.
  ///
  /// O parâmetro [startupId] identifica a startup e [period] define a janela temporal.
  /// O parâmetro [period] deve ser um dos seguintes valores aceitos pelo backend:
  /// - `daily`: dados diários.
  /// - `weekly`: histórico da última semana.
  /// - `monthly`: histórico do último mês.
  /// - `6months`: histórico dos últimos 6 meses.
  /// - `ytd`: acumulado do ano corrente.
  ///
  /// Retorna um [TokenHistoryModel] contendo os snapshots com valores e datas das cotações.
  Future<TokenHistoryModel> fetchHistory(String startupId, String period) async {
    final result = await _functions
        .httpsCallable('onGetTokenHistory')
        .call<Map<String, dynamic>>({
          'startupId': startupId,
          'period':    period,
        });

    return TokenHistoryModel.fromMap(Map<String, dynamic>.from(result.data as Map));
  }
}
