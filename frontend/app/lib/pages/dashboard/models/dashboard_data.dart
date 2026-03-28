/// Modelo de dados consolidado para o Dashboard.
class DashboardData {
  final String nomeUsuario;
  final double patrimonioTotal;
  final double rendimentoDiarioValor;
  final double rendimentoDiarioPorcentagem;
  final int totalStartupsMercado;
  final double rentabilidadeMediaMercado;
  final int totalInvestidoresMercado;

  DashboardData({
    required this.nomeUsuario,
    required this.patrimonioTotal,
    required this.rendimentoDiarioValor,
    required this.rendimentoDiarioPorcentagem,
    required this.totalStartupsMercado,
    required this.rentabilidadeMediaMercado,
    required this.totalInvestidoresMercado,
  });

  /// Mock para desenvolvimento inicial.
  factory DashboardData.mock() {
    return DashboardData(
      nomeUsuario: 'Goretzka',
      patrimonioTotal: 15340.50,
      rendimentoDiarioValor: 245.30,
      rendimentoDiarioPorcentagem: 1.6,
      totalStartupsMercado: 99,
      rentabilidadeMediaMercado: 9.9,
      totalInvestidoresMercado: 9900,
    );
  }
}
