/// Modelo de dados consolidado para o Dashboard.
class InvestimentoResumo {
  final String startupId;
  final String startupName;
  final String startupLogoUrl;
  final int tokenQuantity;
  final double currentPrice;
  final double variation;

  InvestimentoResumo({
    required this.startupId,
    required this.startupName,
    required this.startupLogoUrl,
    required this.tokenQuantity,
    required this.currentPrice,
    required this.variation,
  });

  factory InvestimentoResumo.fromMap(Map<String, dynamic> map) {
    return InvestimentoResumo(
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      startupLogoUrl: map['startupLogoUrl'] as String? ?? '',
      tokenQuantity: (map['tokenQuantity'] as num?)?.toInt() ?? 0,
      currentPrice: (map['currentPrice'] as num?)?.toDouble() ?? 0,
      variation: (map['variation'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DashboardData {
  final String nomeUsuario;
  final double patrimonioTotal;
  final double saldoDisponivel;
  final double rendimentoDiarioValor;
  final double rendimentoDiarioPorcentagem;
  final int totalStartupsMercado;
  final double rentabilidadeMediaMercado;
  final int totalInvestidoresMercado;
  final List<InvestimentoResumo> investimentos;
  final List<String> favoriteIds;

  DashboardData({
    required this.nomeUsuario,
    required this.patrimonioTotal,
    required this.saldoDisponivel,
    required this.rendimentoDiarioValor,
    required this.rendimentoDiarioPorcentagem,
    required this.totalStartupsMercado,
    required this.rentabilidadeMediaMercado,
    required this.totalInvestidoresMercado,
    required this.investimentos,
    required this.favoriteIds,
  });

  factory DashboardData.fromMap(Map<String, dynamic> map) {
    final rawInvestimentos = (map['investimentos'] as List<dynamic>?) ?? [];
    final rawFavorites = (map['favoriteIds'] as List<dynamic>?) ?? [];

    final patrimonioAtivos = (map['patrimonioTotal'] as num?)?.toDouble() ?? 0;
    final saldo = (map['saldoDisponivel'] as num?)?.toDouble() ?? 0;

    return DashboardData(
      nomeUsuario: map['nomeUsuario'] as String? ?? '',
      patrimonioTotal: patrimonioAtivos + saldo,
      saldoDisponivel: saldo,
      rendimentoDiarioValor: (map['rendimentoDiarioValor'] as num?)?.toDouble() ?? 0,
      rendimentoDiarioPorcentagem: (map['rendimentoDiarioPorcentagem'] as num?)?.toDouble() ?? 0,
      totalStartupsMercado: (map['totalStartupsMercado'] as num?)?.toInt() ?? 0,
      rentabilidadeMediaMercado: (map['rentabilidadeMediaMercado'] as num?)?.toDouble() ?? 0,
      totalInvestidoresMercado: (map['totalInvestidoresMercado'] as num?)?.toInt() ?? 0,
      investimentos: rawInvestimentos
          .map((i) => InvestimentoResumo.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList(),
      favoriteIds: rawFavorites.map((f) => f.toString()).toList(),
    );
  }

  /// Mock para fallback.
  factory DashboardData.mock() {
    return DashboardData(
      nomeUsuario: 'Usuário',
      patrimonioTotal: 0,
      saldoDisponivel: 0,
      rendimentoDiarioValor: 0,
      rendimentoDiarioPorcentagem: 0,
      totalStartupsMercado: 0,
      rentabilidadeMediaMercado: 0,
      totalInvestidoresMercado: 0,
      investimentos: [],
      favoriteIds: [],
    );
  }
}
