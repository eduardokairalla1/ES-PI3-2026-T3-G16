/// --- Cartão de Patrimônio do Portfólio ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/core/utils/formatters.dart';
import 'package:mesclainvest/pages/portfolio/widgets/cartao_base.dart';
import 'package:mesclainvest/pages/portfolio/widgets/portfolio_styles.dart';

/// Eu represento o cartão de saldo principal na tela de portfólio.
class CartaoPatrimonioPortfolio extends StatelessWidget {
  final double patrimonioTotal;
  final double lucroTotal;
  final double valorInvestido;
  final double lucroPorToken;
  final int posicoesAtivas;
  final bool isObscured;
  final VoidCallback onToggleVisibility;

  const CartaoPatrimonioPortfolio({
    super.key,
    required this.patrimonioTotal,
    required this.lucroTotal,
    required this.valorInvestido,
    required this.lucroPorToken,
    required this.posicoesAtivas,
    required this.isObscured,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildBalanceRow(),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'MEU PATRIMÔNIO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: PortfolioStyles.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        // Ícone de crescimento + valor do lucro em verde com crossfade
        Row(
          children: [
            const Icon(Icons.trending_up, color: PortfolioStyles.positiveGrowth, size: 16),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isObscured ? r'+R$ ••••' : '+${lucroTotal.toBRL()}',
                key: ValueKey<bool>(isObscured),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: PortfolioStyles.positiveGrowth,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceRow() {
    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              isObscured ? '••••••••' : patrimonioTotal.toBRL(),
              key: ValueKey<bool>(isObscured),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: PortfolioStyles.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Ícone de visibilidade com rotação suave
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: IconButton(
            key: ValueKey<bool>(isObscured),
            onPressed: onToggleVisibility,
            icon: Icon(
              isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: PortfolioStyles.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isObscured ? 0.4 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('Investido', isObscured ? '••••' : valorInvestido.toBRL()),
          _buildStatItem(
            'Lucro p/Token',
            isObscured ? '••••' : lucroPorToken.toBRL(),
            valueColor: PortfolioStyles.positiveGrowth,
          ),
          _buildStatItem('Posições', isObscured ? '••' : posicoesAtivas.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: PortfolioStyles.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? PortfolioStyles.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
