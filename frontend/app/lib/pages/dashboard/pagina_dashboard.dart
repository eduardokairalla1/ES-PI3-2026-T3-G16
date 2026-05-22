/*
 * Página principal do Dashboard do usuário.
 * Centraliza o acesso às principais funcionalidades e resumos da conta.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/widgets/dashboard_skeleton.dart';
import 'package:mesclainvest/pages/dashboard/widgets/deposit_prompt_card.dart';
import 'package:mesclainvest/pages/dashboard/widgets/widgets.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';
import 'package:mesclainvest/shared/widgets/delayed_shimmer.dart';

/// Componente de página (Widget com estado) do Dashboard.
/// Esta tela serve como hub principal para os investidores do Mescla, exibindo
/// o patrimônio total, saldo disponível, atalhos de ações (depósito/saque/hub)
/// e listando os investimentos do investidor bem como as startups em destaque no ecossistema.
class PaginaDashboard extends StatefulWidget {
  final String? initialFilter;
  const PaginaDashboard({super.key, this.initialFilter});

  @override
  State<PaginaDashboard> createState() => _PaginaDashboardState();
}

class _PaginaDashboardState extends State<PaginaDashboard> {
  // Controlador responsável pela lógica de negócios da página (MVVM)
  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _controller.filterStartups(widget.initialFilter);
    }
    // Inicializa a carga assíncrona dos dados do painel do usuário
    _controller.loadDashboard();
  }

  @override
  void didUpdateWidget(covariant PaginaDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != oldWidget.initialFilter) {
      _controller.filterStartups(widget.initialFilter);
    }
  }

  @override
  void dispose() {
    // Libera os recursos alocados pelo controlador ao descartar a página
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reconstrói a UI dinamicamente sempre que o estado do controlador mudar (ex: carregamento finalizado)
    return AnimatedBuilder(
      animation: _controller,
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

  /// Constrói o corpo principal da página com todos os componentes/seções do Dashboard.
  Widget _buildContent() {
    // --- Pedro Henrique Medeiros dos Reis - 24801656 ---
    // Show the "deposit to get started" card at the top whenever the wallet
    // is empty — softens the empty dashboard for brand-new users.
    final showDepositPrompt = (_controller.data?.saldoDisponivel ?? 0) <= 0;
    // --- end Pedro ---

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoDashboard(controller: _controller),
          CartaoPatrimonio(controller: _controller),
          if (showDepositPrompt) DepositPromptCard(controller: _controller),
          BotoesAcao(controller: _controller),
          StartupsEcossistema(controller: _controller),
          MeusInvestimentos(controller: _controller),
        ],
      ),
    );
  }

  /// Constrói a UI para exibição de mensagens de erro amigáveis (ex: falhas de conectividade).
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
              label: 'Tentar novamente',
              size: AppButtonSize.small,
              fullWidth: false,
              onPressed: _controller.loadDashboard,
            ),
          ],
        ),
      ),
    );
  }
}
