/// --- Portfolio service ---

import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';

/// I provide data for the portfolio screen.
class PortfolioService {

  /// I fetch portfolio data, simulating a network delay.
  ///
  /// :returns: Future containing PortfolioData.
  Future<PortfolioData> getPortfolioData() async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));

    // return mock data
    return PortfolioData.mock();
  }

}
