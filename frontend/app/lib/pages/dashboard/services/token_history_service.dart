/// Serviço de histórico de preços de tokens.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/dashboard/models/price_snapshot_model.dart';


class TokenHistoryService {

  final _functions = FirebaseFunctions.instance;

  /// I fetch token price history for [startupId] in the given [period].
  ///
  /// [period] must be one of: daily, weekly, monthly, 6months, ytd
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
