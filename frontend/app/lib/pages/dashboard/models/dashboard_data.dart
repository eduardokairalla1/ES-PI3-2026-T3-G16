/*
 * Modelos de dados do Dashboard.
 * Define os contratos consumidos pela UI a partir das Cloud Functions.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */
library;

/*
 * TYPES
 */

/// Modelo que representa o resumo da posição de investimentos de um investidor em uma startup específica.
class InvestimentoResumo {
  /// Identificador único da startup (Doc ID do Firestore).
  final String startupId;
  
  /// Nome de exibição da startup.
  final String startupName;
  
  /// URL contendo a imagem do logotipo da startup.
  final String startupLogoUrl;
  
  /// Quantidade total de tokens em custódia.
  final int tokenQuantity;
  
  /// Cotação/Preço atual do token no mercado.
  final double currentPrice;
  
  /// Variação percentual ponderada de valorização/desvalorização do ativo (com base no preço médio).
  final double variation;

  InvestimentoResumo({
    required this.startupId,
    required this.startupName,
    required this.startupLogoUrl,
    required this.tokenQuantity,
    required this.currentPrice,
    required this.variation,
  });

  /// Cria um resumo de investimento a partir de um mapa de chaves/valores (`Map<String, dynamic>`) retornado pelo backend.
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

/// Dados consolidados do Dashboard consumidos pela interface gráfica para renderização do painel principal.
class DashboardData {
  /// Nome completo do investidor logado.
  final String nomeUsuario;
  
  /// Patrimônio total do investidor (Soma dos ativos em custódia + saldo disponível líquido).
  final double patrimonioTotal;
  
  /// Saldo líquido disponível em conta para novos investimentos e saques.
  final double saldoDisponivel;
  
  /// Rendimento bruto em valor monetário acumulado no portfólio do usuário na última semana.
  final double rendimentoDiarioValor;
  
  /// Variação percentual de rendimento do portfólio na última semana.
  final double rendimentoDiarioPorcentagem;
  
  /// Número total de startups ativas registradas e disponíveis para investimento no ecossistema.
  final int totalStartupsMercado;
  
  /// Rentabilidade média geral calculada das startups do ecossistema nos últimos 30 dias.
  final double rentabilidadeMediaMercado;
  
  /// Contagem total de investidores ativos (que possuem ordens de compra completadas) no ecossistema.
  final int totalInvestidoresMercado;
  
  /// Lista contendo as posições de investimento ativas do usuário.
  final List<InvestimentoResumo> investimentos;
  
  /// Lista contendo os identificadores de startups favoritadas pelo investidor.
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

  /// Cria a entidade de visualização consolidada a partir do mapa gerado pela chamada à Cloud Function `onGetDashboard`.
  /// Agrega o patrimônio total combinando o valor de custódia com o saldo líquido em carteira.
  factory DashboardData.fromMap(Map<String, dynamic> map) {
    final rawInvestimentos = (map['investimentos'] as List<dynamic>?) ?? [];
    final rawFavorites = (map['favoriteIds'] as List<dynamic>?) ?? [];

    final patrimonioAtivos = (map['patrimonioTotal'] as num?)?.toDouble() ?? 0;
    final saldo = (map['saldoDisponivel'] as num?)?.toDouble() ?? 0;

    return DashboardData(
      nomeUsuario: map['nomeUsuario'] as String? ?? '',
      patrimonioTotal: patrimonioAtivos + saldo,
      saldoDisponivel: saldo,
      rendimentoDiarioValor:
          (map['rendimentoDiarioValor'] as num?)?.toDouble() ?? 0,
      rendimentoDiarioPorcentagem:
          (map['rendimentoDiarioPorcentagem'] as num?)?.toDouble() ?? 0,
      totalStartupsMercado: (map['totalStartupsMercado'] as num?)?.toInt() ?? 0,
      rentabilidadeMediaMercado:
          (map['rentabilidadeMediaMercado'] as num?)?.toDouble() ?? 0,
      totalInvestidoresMercado:
          (map['totalInvestidoresMercado'] as num?)?.toInt() ?? 0,
      investimentos: rawInvestimentos
          .map(
            (i) =>
                InvestimentoResumo.fromMap(Map<String, dynamic>.from(i as Map)),
          )
          .toList(),
      favoriteIds: rawFavorites.map((f) => f.toString()).toList(),
    );
  }

  /// Instância auxiliar estática para fallback ou estados iniciais de carregamento vazio.
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
