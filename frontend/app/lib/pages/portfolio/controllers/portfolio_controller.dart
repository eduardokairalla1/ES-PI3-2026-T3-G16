/// --- Portfolio controller ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';
import 'package:mesclainvest/pages/portfolio/services/portfolio_service.dart';

/// I manage the state of the portfolio screen.
class PortfolioController extends ChangeNotifier {

  final PortfolioService _service = PortfolioService();

  PortfolioData? _data;
  bool _isLoading = false;
  bool _isObscured = false;

  // getters
  PortfolioData? get data => _data;
  bool get isLoading => _isLoading;
  bool get isObscured => _isObscured;


  /// I initialize the controller and load data.
  PortfolioController() {
    loadPortfolio();
  }


  /// I fetch the portfolio data from the service.
  Future<void> loadPortfolio() async {
    _isLoading = true;
    notifyListeners();

    try {
      _data = await _service.getPortfolioData();
    } catch (e) {
      // handle error if needed
      debugPrint('Error loading portfolio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// I toggle the visibility of sensitive data (balance).
  void toggleVisibility() {
    _isObscured = !_isObscured;
    notifyListeners();
  }

}
