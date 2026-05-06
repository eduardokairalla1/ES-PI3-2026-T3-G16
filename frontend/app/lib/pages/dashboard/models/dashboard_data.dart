/// Modelo de dados consolidado para o Dashboard.
class DashboardData {
  final String nomeUsuario;
  final double patrimonioTotal;
  final double rendimentoSemanalValor;
  final double rendimentoSemanalPorcentagem;
  final int totalStartupsMercado;
  final double rentabilidadeMediaMercado;
  final int totalInvestidoresMercado;

  DashboardData({
    required this.nomeUsuario,
    required this.patrimonioTotal,
    required this.rendimentoSemanalValor,
    required this.rendimentoSemanalPorcentagem,
    required this.totalStartupsMercado,
    required this.rentabilidadeMediaMercado,
    required this.totalInvestidoresMercado,
  });

  factory DashboardData.fromMap(Map<String, dynamic> map, String nomeUsuario) {
    return DashboardData(
      nomeUsuario:                 nomeUsuario,
      patrimonioTotal:             (map['patrimonioTotal'] as num).toDouble(),
      rendimentoSemanalValor:       (map['weeklyReturn']    as num).toDouble(),
      rendimentoSemanalPorcentagem: (map['weeklyReturnPct'] as num).toDouble(),
      totalStartupsMercado:        0,
      rentabilidadeMediaMercado:   0.0,
      totalInvestidoresMercado:    0,
    );
  }

  /// Mock para desenvolvimento inicial.
  factory DashboardData.mock() {
    return DashboardData(
      nomeUsuario: 'Goretzka',
      patrimonioTotal: 15340.50,
      rendimentoSemanalValor: 245.30,
      rendimentoSemanalPorcentagem: 1.6,
      totalStartupsMercado: 99,
      rentabilidadeMediaMercado: 9.9,
      totalInvestidoresMercado: 9900,
    );
  }
}
