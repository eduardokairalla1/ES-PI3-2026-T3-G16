/// --- Modelo de Dados do Dashboard ---
/// Representa o estado dos dados do usuário na tela principal.

class DashboardData {
  
  final double patrimonioTotal;
  final double rentabilidadeDiariaValor;
  final double rentabilidadeDiariaPercentual;

  DashboardData({
    required this.patrimonioTotal,
    required this.rentabilidadeDiariaValor,
    required this.rentabilidadeDiariaPercentual,
  });

  /// Fábrica de mock para testes iniciais
  factory DashboardData.mock() {
    return DashboardData(
      patrimonioTotal: 999999999.99,
      rentabilidadeDiariaValor: 9999.99,
      rentabilidadeDiariaPercentual: 9.99,
    );
  }
}
