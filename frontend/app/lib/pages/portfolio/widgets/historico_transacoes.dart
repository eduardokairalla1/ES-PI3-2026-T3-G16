/// --- Histórico de Transações ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/models/portfolio_data.dart';
import 'package:mesclainvest/pages/portfolio/widgets/cartao_base.dart';
import 'package:mesclainvest/pages/portfolio/widgets/portfolio_styles.dart';

/// Eu represento um cartão mostrando uma lista de transações recentes.
class HistoricoTransacoes extends StatelessWidget {
  final List<PortfolioTransaction> transacoes;

  const HistoricoTransacoes({
    super.key,
    required this.transacoes,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico de Transações',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PortfolioStyles.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transacoes.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) => _ItemTransacao(transacao: transacoes[index]),
          ),
        ],
      ),
    );
  }
}

/// Eu represento uma única linha no histórico de transações.
class _ItemTransacao extends StatelessWidget {
  final PortfolioTransaction transacao;
  const _ItemTransacao({required this.transacao});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 12),
        Expanded(child: _buildInfo()),
        _buildValue(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        transacao.isCompra ? Icons.arrow_outward : Icons.arrow_downward,
        color: PortfolioStyles.textPrimary,
        size: 20,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${transacao.isCompra ? 'Compra' : 'Venda'} - ${transacao.subtitulo}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: PortfolioStyles.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          transacao.data,
          style: const TextStyle(fontSize: 12, color: PortfolioStyles.textSecondary),
        ),
      ],
    );
  }

  Widget _buildValue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '+${transacao.quantidade} STX',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: PortfolioStyles.positiveGrowth,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Valor em R\$',
          style: TextStyle(fontSize: 10, color: PortfolioStyles.textSecondary),
        ),
      ],
    );
  }
}
