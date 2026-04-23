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
        // Ícone de crescimento + valor do lucro em verde
        Row(
          children: [
            const Icon(Icons.trending_up, color: PortfolioStyles.positiveGrowth, size: 16),
            const SizedBox(width: 4),
            Text(
              isObscured ? r'+R$ ••••' : '+${lucroTotal.toBRL()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: PortfolioStyles.positiveGrowth,
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
          child: Text(
            isObscured ? '••••••••' : patrimonioTotal.toBRL(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: PortfolioStyles.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: PortfolioStyles.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
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
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? PortfolioStyles.textPrimary,
          ),
        ),
      ],
    );
  }
}
