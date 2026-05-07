/**
 * Widget de resumo do mercado, exibindo estatísticas gerais da plataforma.
 * Exibe o total de startups, rentabilidade média e volume de investidores.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * IMPORTS
 */
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/stats_box.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';


/**
 * CODE
 */

/// Seção horizontal com indicadores de performance do ecossistema MesclaInvest.
class ResumoMercado extends StatelessWidget {
  
  // Atributos
  final DashboardController controller;
  
  // Construtor
  const ResumoMercado({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    // --- Formatação: Rentabilidade Média ---
    final rentabilidade = data.rentabilidadeMediaMercado;
    final sinal = rentabilidade > 0 ? '+' : '';
    final rentabilidadeStr = '$sinal${rentabilidade.toStringAsFixed(1).replaceAll('.', ',')}%';

    // --- Formatação: Volume de Investidores (Abreviado ex: 1,5k) ---
    final investidores = data.totalInvestidoresMercado;
    final investidoresStr = investidores >= 1000 
        ? '${(investidores / 1000).toStringAsFixed(1).replaceAll('.', ',')}k'
        : investidores.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      // Grade horizontal de indicadores (StatsBox)
      child: Row(
        children: [
          // Total de startups listadas
          StatsBox(
            primaryText: data.totalStartupsMercado.toString(),
            secondaryText: 'Startups\ndisponíveis',
          ),
          const SizedBox(width: 12),
          
          // Rentabilidade acumulada do mercado no mês
          StatsBox(
            primaryText: rentabilidadeStr,
            secondaryText: 'Rentabilidade\neste mês',
          ),
          const SizedBox(width: 12),
          
          // Quantidade de usuários ativos na plataforma
          StatsBox(
            primaryText: investidoresStr,
            secondaryText: 'Investidores\nativos',
          ),
        ],
      ),
    );
  }
}
