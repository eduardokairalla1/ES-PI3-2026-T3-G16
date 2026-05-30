// --- Full investments list page ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Dedicated screen that lists every token the user currently holds. Reached
// from the "Ver todos" link on the carteira/dashboard portfolio section.
//
// Reuses [InvestimentoCard] (defined in the dashboard widget) so the visual
// matches the summary view 1:1 — the only difference here is that the list
// is unbounded (no `.take(N)`) and lives in its own scaffold so the user can
// dive deep without the surrounding patrimônio/charts/transactions clutter.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/widgets/meus_investimentos.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- CONSTANTS ---

final _currencyFmt = NumberFormat.currency(
  locale:         'pt_BR',
  symbol:         'R\$',
  decimalDigits:  2,
);

// --- PAGE ---

/// Full-screen list of every token in the user's wallet.
///
/// Lives at `/carteira/investimentos`. Owns its own [DashboardController]
/// instance — payload is the same one used by the carteira/dashboard so we
/// get the holdings list without a new backend endpoint.
class InvestimentosPage extends StatefulWidget {
  const InvestimentosPage({super.key});

  @override
  State<InvestimentosPage> createState() => _InvestimentosPageState();
}

class _InvestimentosPageState extends State<InvestimentosPage> {
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
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          appBar: AppBar(
            backgroundColor: AppColors.surfaceColor(context),
            foregroundColor: AppColors.textPrimary(context),
            elevation: 0,
            scrolledUnderElevation: 0,
            shape: Border(bottom: BorderSide(color: AppColors.border(context))),
            title: const Text(
              'Meus Investimentos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            centerTitle: true,
          ),
          body: SafeArea(child: _buildBody()),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary(context)),
      );
    }

    if (_controller.errorMessage != null) {
      return _ErrorView(
        message: _controller.errorMessage!,
        onRetry: _controller.loadDashboard,
      );
    }

    final list = _controller.data?.investimentos ?? const [];

    if (list.isEmpty) return const _EmptyView();

    return RefreshIndicator(
      color:    AppColors.textPrimary(context),
      onRefresh: _controller.loadDashboard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SummaryHeader(count: list.length, totalAplicado: _totalAplicado(list)),
          const SizedBox(height: 16),
          for (final i in list)
            InvestimentoCard(
              investimento:  i,
              exibirValores: _controller.exibirValores,
            ),
        ],
      ),
    );
  }

  /// Sum of (qty × current price) across all holdings — represents the
  /// total value currently invested in tokens (excludes idle wallet cash).
  double _totalAplicado(List<dynamic> list) {
    double sum = 0;
    for (final i in list) {
      sum += (i.tokenQuantity as int) * (i.currentPrice as double);
    }
    return sum;
  }
}

// --- INTERNAL: SUMMARY HEADER ---

class _SummaryHeader extends StatelessWidget {
  final int count;
  final double totalAplicado;
  const _SummaryHeader({required this.count, required this.totalAplicado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STARTUPS',
                  style: TextStyle(
                    fontSize:    10,
                    fontWeight:  FontWeight.w800,
                    color:       AppColors.textMuted(context),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize:    22,
                    fontWeight:  FontWeight.w800,
                    color:       AppColors.textPrimary(context),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border(context)),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TOTAL APLICADO',
                  style: TextStyle(
                    fontSize:    10,
                    fontWeight:  FontWeight.w800,
                    color:       AppColors.textMuted(context),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currencyFmt.format(totalAplicado),
                  style: moneyStyle(
                    fontSize: 22,
                    color:    AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- INTERNAL: STATES ---

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size:  56,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Você ainda não possui investimentos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:   15,
                fontWeight: FontWeight.w600,
                color:      AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Compre tokens de uma startup para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color:    AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.textMuted(context)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            AppButton(
              label:     'Tentar novamente',
              size:      AppButtonSize.small,
              fullWidth: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
