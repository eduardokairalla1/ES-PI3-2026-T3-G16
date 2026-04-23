/// --- Histórico de Transações ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/core/utils/formatters.dart';
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
          _buildTransactionList(),
          const SizedBox(height: 12),
          _buildFooterButton(),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transacoes.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) => _ItemTransacao(transacao: transacoes[index]),
    );
  }

  Widget _buildFooterButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Ver extrato completo',
          style: TextStyle(
            color: PortfolioStyles.primaryAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
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
    final statusColor = transacao.isCompra ? PortfolioStyles.positiveGrowth : PortfolioStyles.negativeGrowth;

    return Row(
      children: [
        _buildIcon(statusColor),
        const SizedBox(width: 12),
        Expanded(child: _buildInfo()),
        _buildValue(statusColor),
      ],
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        transacao.isCompra ? Icons.add_circle_outline : Icons.remove_circle_outline,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transacao.titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: PortfolioStyles.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          transacao.subtitulo,
          style: const TextStyle(fontSize: 12, color: PortfolioStyles.textSecondary),
        ),
      ],
    );
  }

  Widget _buildValue(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${transacao.isCompra ? '+' : '-'} ${transacao.valor.toBRL()}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          transacao.data,
          style: const TextStyle(fontSize: 10, color: PortfolioStyles.textSecondary),
        ),
      ],
    );
  }
}
