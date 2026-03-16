// --- Dashboard page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/core/services/auth.dart';


// --- CODE ---

/// I represent the dashboard page.
class DashboardPage extends StatelessWidget {

  // constructor
  const DashboardPage({super.key});


  /// I build the widget tree for the dashboard page.
  /// 
  /// :returns: the widget tree for this page
  @override
  Widget build(BuildContext context) {

    // get the auth service
    final authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // TODO: Header - App Brand
              // TODO: Patrimônio card
              // TODO: Action buttons (Depositar, Comprar, Vender, etc.)
              // TODO: Stats row (Startups, Rentabilidade, Investidores)
              // TODO: Startups do Ecossistema
              // TODO: Meus Investimentos

            ],
          ),
        ),
      ),
    );
  }
}
