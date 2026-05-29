/*
 * Widget de resumo do mercado, exibindo estatísticas gerais da plataforma.
 * Exibe o total de startups, rentabilidade média e volume de investidores.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

library;

/*
 * IMPORTS
 */

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/stats_box.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';

/*
 * CODE
 */

/// Seção horizontal que apresenta os principais indicadores de performance do ecossistema Mescla.
/// Contém 3 blocos informativos:
/// 1. Quantidade de startups listadas.
/// 2. Rentabilidade média ponderada das cotações de tokens.
/// 3. Contagem consolidada de investidores ativos (com abreviação matemática ex: "1,5k").
class ResumoMercado extends StatelessWidget {
  /// Instância do controlador do Dashboard fornecendo os dados estatísticos.
  final DashboardController controller;

  const ResumoMercado({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    // --- Formatação da Maior Alta do Mês ---
    final maiorAltaPct  = data.maiorAltaPct;
    final maiorAltaNome = data.maiorAltaNome;
    final String maiorAltaPrimaryText;
    final String maiorAltaSecondaryText;
    if (maiorAltaPct != null && maiorAltaNome != null) {
      final sinal = maiorAltaPct >= 0 ? '+' : '';
      maiorAltaPrimaryText   = '$sinal${maiorAltaPct.toStringAsFixed(1).replaceAll('.', ',')}%';
      // Trunca nomes muito longos para caber no card
      final nome = maiorAltaNome.length > 12
          ? '${maiorAltaNome.substring(0, 11)}…'
          : maiorAltaNome;
      maiorAltaSecondaryText = '$nome\nMaior alta';
    } else {
      maiorAltaPrimaryText   = '—';
      maiorAltaSecondaryText = 'Maior alta\neste mês';
    }

    // --- Formatação do Volume de Investidores (Abrevia milhares com "k" ex: 1500 -> 1,5k) ---
    final investidores = data.totalInvestidoresMercado;
    final investidoresStr = investidores >= 1000
        ? '${(investidores / 1000).toStringAsFixed(1).replaceAll('.', ',')}k'
        : investidores.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Bloco 1: Total de startups cadastradas
          StatsBox(
            primaryText: data.totalStartupsMercado.toString(),
            secondaryText: 'Startups\ndisponíveis',
          ),
          const SizedBox(width: 12),

          // Bloco 2: Startup com maior valorização no mês
          StatsBox(
            primaryText: maiorAltaPrimaryText,
            secondaryText: maiorAltaSecondaryText,
          ),
          const SizedBox(width: 12),

          // Bloco 3: Número de investidores ativos
          StatsBox(
            primaryText: investidoresStr,
            secondaryText: 'Investidores\nativos',
          ),
        ],
      ),
    );
  }
}
