/// --- Modelo de dados do portfólio ---

/// Eu represento a estrutura de dados para a tela de portfólio.
class PortfolioData {

  final String userName;
  final double patrimonioTotal;
  final double lucroTotal;
  final double valorInvestido;
  final double lucroPorToken;
  final int posicoesAtivas;
  final List<PortfolioTransaction> transacoes;
  final List<PortfolioDistribution> distribuicao;
  final List<double> evolucaoPontos;

  // construtor
  PortfolioData({
    required this.userName,
    required this.patrimonioTotal,
    required this.lucroTotal,
    required this.valorInvestido,
    required this.lucroPorToken,
    required this.posicoesAtivas,
    required this.transacoes,
    required this.distribuicao,
    required this.evolucaoPontos,
  });

  /// Eu crio uma instância mock de PortfolioData para fins de teste.
  factory PortfolioData.mock() {
    return PortfolioData(
      userName: 'Alex Gabriel',
      patrimonioTotal: 999450.50,
      lucroTotal: 24500.00,
      valorInvestido: 974950.50,
      lucroPorToken: 12.50,
      posicoesAtivas: 12,
      evolucaoPontos: [10, 25, 15, 30, 45, 40, 60],
      transacoes: [
        PortfolioTransaction(
          titulo: 'Compra de Tokens',
          subtitulo: 'FinnoLab - Série A',
          data: '23 Abr, 10:30',
          valor: 1500.00,
          isCompra: true,
        ),
        PortfolioTransaction(
          titulo: 'Venda de Tokens',
          subtitulo: 'DataBrave - Exit',
          data: '20 Abr, 15:45',
          valor: 2450.00,
          isCompra: false,
        ),
      ],
      distribuicao: [
        PortfolioDistribution(nome: 'FinnoLab', percentual: 0.45),
        PortfolioDistribution(nome: 'DataBrave', percentual: 0.30),
        PortfolioDistribution(nome: 'GreenLoop', percentual: 0.25),
      ],
    );
  }
}

/// Eu represento uma única transação no histórico do portfólio.
class PortfolioTransaction {
  final String titulo;
  final String subtitulo;
  final String data;
  final double valor;
  final bool isCompra;

  PortfolioTransaction({
    required this.titulo,
    required this.subtitulo,
    required this.data,
    required this.valor,
    required this.isCompra,
  });
}

/// Eu represento um segmento no gráfico de distribuição do portfólio.
class PortfolioDistribution {
  final String nome;
  final double percentual;

  PortfolioDistribution({
    required this.nome,
    required this.percentual,
  });
}
