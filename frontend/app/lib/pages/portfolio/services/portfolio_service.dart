/// --- Serviço de portfólio ---

import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';

/// Eu forneço dados para a tela de portfólio.
class PortfolioService {

  /// Eu busco os dados do portfólio, simulando um atraso de rede.
  ///
  /// :returns: Future contendo PortfolioData.
  Future<PortfolioData> getPortfolioData() async {
    // simula latência de rede
    await Future.delayed(const Duration(milliseconds: 800));

    // retorna dados mock
    return PortfolioData.mock();
  }

}
