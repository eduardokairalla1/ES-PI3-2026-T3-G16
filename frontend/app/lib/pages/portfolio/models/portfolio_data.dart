/// --- Portfolio data model ---

/// I represent the data structure for the portfolio screen.
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

  // constructor
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

  /// I create a mock instance of PortfolioData for testing purposes.
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

/// I represent a single transaction in the portfolio history.
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

/// I represent a segment in the portfolio distribution chart.
class PortfolioDistribution {
  final String nome;
  final double percentual;

  PortfolioDistribution({
    required this.nome,
    required this.percentual,
  });
}
