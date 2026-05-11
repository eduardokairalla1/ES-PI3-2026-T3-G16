/*
 * Service do Dashboard.
 * Encapsula as chamadas às Cloud Functions usadas pela tela de Dashboard.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */
library;

<<<<<<< HEAD
/*
 * IMPORTS
 */

import 'package:cloud_functions/cloud_functions.dart';
=======
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/app/app_state.dart';
>>>>>>> pr-65-davi
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';

/*
 * CODE
 */

/// Integração de dados do Dashboard com APIs e Firebase.
class DashboardService {
  final _functions = FirebaseFunctions.instance;

  /// Consulta dados consolidados do usuário.
  Future<DashboardData> fetchUserDashboardData() async {
<<<<<<< HEAD
    final result = await _functions
        .httpsCallable('onGetDashboard')
        .call<Map<String, dynamic>>();

    return DashboardData.fromMap(Map<String, dynamic>.from(result.data));
=======
    final result = await FirebaseFunctions.instance
        .httpsCallable('onGetWallet')
        .call();

    final raw = result.data;
    final data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);

    final nome = AppState.instance.profile?.fullName ?? '';
    return DashboardData.fromMap(data, nome);
>>>>>>> pr-65-davi
  }

  /// Alterna o status de favorito para uma startup.
  Future<bool> toggleFavorite(String startupId) async {
    final result = await _functions
        .httpsCallable('onToggleFavorite')
        .call<Map<String, dynamic>>({'startupId': startupId});

    return (result.data as Map)['isFavorited'] as bool;
  }

  /// Realiza um depósito simulado.
  Future<double> deposit(double amount) async {
    final result = await _functions
        .httpsCallable('onDeposit')
        .call<Map<String, dynamic>>({'amount': amount});

    return (result.data['newBalance'] as num).toDouble();
  }

  /// Busca o histórico de transações.
  Future<List<Map<String, dynamic>>> getTransactions({int limit = 20}) async {
    final result = await _functions
        .httpsCallable('onGetTransactions')
        .call<Map<String, dynamic>>({'limit': limit});

    final List<dynamic> list = result.data['transactions'] ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
