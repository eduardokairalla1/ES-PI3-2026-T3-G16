/// Seção de ativos na carteira do usuário.
/// Exibe valorização e quantidade de tokens por startup.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:mesclainvest/shared/styles/stage_colors.dart';


// --- HELPERS ---

final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);


// --- SEÇÃO ---

class MeusInvestimentos extends StatelessWidget {

  final List<PortfolioItemModel> portfolio;

  const MeusInvestimentos({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    if (portfolio.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'MEUS INVESTIMENTOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFAAAAAA),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...portfolio.map(
          (item) => _PortfolioCard(item: item),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}


// --- CARD ---

class _PortfolioCard extends StatelessWidget {

  final PortfolioItemModel item;

  const _PortfolioCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = stageColor(item.stage);

    return GestureDetector(
      onTap: () => context.push('/startup/${item.startupId}/valorizacao'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // logo + nome + estágio
            Row(
              children: [
                _Logo(url: item.logoUrl, name: item.startupName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.startupName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _stageLabel(item.stage),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 14),

            // valor total + variação + tokens
            Row(
              children: [
                _Stat(
                  label: 'Valor total',
                  value: _currencyFmt.format(item.totalValue),
                ),
                const SizedBox(width: 24),
                _Stat(
                  label: 'Tokens',
                  value: item.tokenQuantity.toString(),
                ),
                const Spacer(),
                // variação desde a compra
                Row(
                  children: [
                    Icon(
                      item.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 13,
                      color: item.isPositive ? Colors.green : Colors.red,
                    ),
                    Text(
                      '${item.changePercent.abs().toStringAsFixed(2)}%',
                      style: moneyStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: item.isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFFAAAAAA)),
              ],
            ),

          ],
        ),
      ),
    );
  }

  String _stageLabel(String stage) => switch (stage) {
    'new'       => 'Nova',
    'operating' => 'Em operação',
    'expanding' => 'Em expansão',
    _           => stage,
  };
}


// --- SUB-WIDGETS (reusados do padrão de startup_card) ---

class _Logo extends StatelessWidget {
  final String url;
  final String name;

  const _Logo({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFFAAAAAA),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: moneyStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
