/// Integração de dados do Dashboard com APIs e Firebase.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';

class DashboardService {

  /// Consulta dados consolidados do usuário.
  Future<DashboardData> fetchUserDashboardData() async {
    final result = await FirebaseFunctions.instance
        .httpsCallable('onGetWallet')
        .call();

    final raw = result.data;
    final data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);

    final nome = AppState.instance.profile?.fullName ?? '';
    return DashboardData.fromMap(data, nome);
  }

}
