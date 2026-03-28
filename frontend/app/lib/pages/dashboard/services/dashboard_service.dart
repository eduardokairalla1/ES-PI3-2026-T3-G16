/// Integração de dados do Dashboard com APIs e Firebase.

import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';

class DashboardService {

  /// Consulta dados consolidados do usuário.
  Future<DashboardData> fetchUserDashboardData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulação de latência.
    return DashboardData.mock();
  }

}
