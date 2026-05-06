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
}
