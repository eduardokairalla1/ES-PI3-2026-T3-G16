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
      userName: 'Renata',
      patrimonioTotal: 999999999.99,
      lucroTotal: 9999.99,
      valorInvestido: 9999.99,
      lucroPorToken: 9999.99,
      posicoesAtivas: 99,
      evolucaoPontos: [10, 25, 15, 30, 45, 40, 60],
      transacoes: [
        PortfolioTransaction(
          titulo: 'Compra',
          subtitulo: 'Startup XXXX',
          data: 'Data/99/9999',
          valor: 9999.99,
          quantidade: 999,
          isCompra: true,
        ),
        PortfolioTransaction(
          titulo: 'Venda',
          subtitulo: 'Startup XXXX',
          data: 'Data/99/9999',
          valor: 9999.99,
          quantidade: 999,
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
  final int quantidade;
  final bool isCompra;

  PortfolioTransaction({
    required this.titulo,
    required this.subtitulo,
    required this.data,
    required this.valor,
    required this.quantidade,
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
