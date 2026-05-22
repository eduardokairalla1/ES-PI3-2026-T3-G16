// --- Carteira page ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Investment-portfolio dashboard accessible from the bottom nav. Consolidates
// everything related to the user's money in a single screen:
//   1. User header (same component as the dashboard).
//   2. "MEU PATRIMÔNIO" — total net worth + daily variation + cash available
//      (reuses [CartaoPatrimonio] from the dashboard).
//   3. "Evolução do Patrimônio" — line chart showing how the total has moved
//      over the selected period (illustrative trend derived from the current
//      daily variation since we don't store historical patrimônio snapshots).
//   4. "Distribuição do Patrimônio" — donut chart breaking down the user's
//      holdings by startup, with a side legend.
//   5. "Histórico de Transações" — recent buys/sells/deposits in the same
//      visual style as the extrato dialog from the dashboard.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/carteira/widgets/distribuicao_patrimonio_card.dart';
import 'package:mesclainvest/pages/carteira/widgets/evolucao_patrimonio_card.dart';
import 'package:mesclainvest/pages/carteira/widgets/historico_transacoes_card.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/widgets/cabecalho_dashboard.dart';
import 'package:mesclainvest/pages/dashboard/widgets/cartao_patrimonio.dart';
import 'package:mesclainvest/pages/dashboard/widgets/dashboard_skeleton.dart';
import 'package:mesclainvest/pages/dashboard/widgets/meus_investimentos.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';
import 'package:mesclainvest/shared/widgets/delayed_shimmer.dart';

// --- PAGE ---

/// Consolidated wallet/portfolio page.
///
/// Lives at `/carteira` and is the fifth tab in the bottom navigation. Owns
/// its own [DashboardController] instance — the backend payload is the same
/// one used by the dashboard, so we get patrimônio + holdings + recent
/// transactions in a single call without inventing a new endpoint.
class CarteiraPage extends StatefulWidget {
  const CarteiraPage({super.key});

  @override
  State<CarteiraPage> createState() => _CarteiraPageState();
}

class _CarteiraPageState extends State<CarteiraPage> {
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
    // Listen to both the controller AND AppState so the user header re-renders
    // when the profile finishes loading (Firebase Auth restores async on web).
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, AppState.instance]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            bottom: false,
            child: DelayedShimmer(
              isLoading: _controller.isLoading,
              skeleton: const DashboardSkeleton(),
              child: _controller.errorMessage != null
                  ? _buildError()
                  : _buildContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoDashboard(controller: _controller),
          CartaoPatrimonio(controller: _controller),
          EvolucaoPatrimonioCard(controller: _controller),
          DistribuicaoPatrimonioCard(controller: _controller),
          MeusInvestimentos(controller: _controller),
          HistoricoTransacoesCard(controller: _controller),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.textMuted(context)),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            AppButton(
              label:     'Tentar novamente',
              size:      AppButtonSize.small,
              fullWidth: false,
              onPressed: _controller.loadDashboard,
            ),
          ],
        ),
      ),
    );
  }
}
