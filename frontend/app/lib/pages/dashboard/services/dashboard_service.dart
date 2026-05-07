/// Integração de dados do Dashboard com APIs e Firebase.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';

class DashboardService {
  final _functions = FirebaseFunctions.instance;

  /// Consulta dados consolidados do usuário.
  Future<DashboardData> fetchUserDashboardData() async {
    final result = await _functions
        .httpsCallable('onGetDashboard')
        .call<Map<String, dynamic>>();

    return DashboardData.fromMap(Map<String, dynamic>.from(result.data));
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

