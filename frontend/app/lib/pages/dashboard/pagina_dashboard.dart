/// View principal do Dashboard.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/widgets.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';

/// Tela principal que compõe o Dashboard.
class PaginaDashboard extends StatefulWidget {

  const PaginaDashboard({super.key});

  @override
  State<PaginaDashboard> createState() => _PaginaDashboardState();
}

class _PaginaDashboardState extends State<PaginaDashboard> {
  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CabecalhoDashboard(controller: _controller),
                        CartaoPatrimonio(controller: _controller),
                        BotoesAcao(controller: _controller),
                        StartupsEcossistema(controller: _controller),

                        MeusInvestimentos(controller: _controller),
                      ],
                    ),
                  ),
          ),
          bottomNavigationBar: const SafeArea(
            child: BottomNav(currentIndex: 0),
          ),
        );
      },
    );
  }
}
