/// --- Serviço do Dashboard ---
/// Responsável por buscar dados reais de APIs externas ou Firebase.

import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';

class DashboardService {

  /// Busca os dados agregados do usuário para popular o Dashboard.
  Future<DashboardData> fetchUserDashboardData() async {
    await Future.delayed(const Duration(seconds: 1)); // simulando rede
    return DashboardData.mock();
  }

}
