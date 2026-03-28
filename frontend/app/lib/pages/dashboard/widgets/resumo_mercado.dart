import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/stats_box.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';

/// Seção de indicadores de mercado.
class ResumoMercado extends StatelessWidget {
  final DashboardController controller;
  
  const ResumoMercado({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    // Formatação de rentabilidade.
    final rentabilidade = data.rentabilidadeMediaMercado;
    final sinal = rentabilidade > 0 ? '+' : '';
    final rentabilidadeStr = '$sinal${rentabilidade.toStringAsFixed(1).replaceAll('.', ',')}%';

    // Formatação de volume de investidores.
    final investidores = data.totalInvestidoresMercado;
    final investidoresStr = investidores >= 1000 
        ? '${(investidores / 1000).toStringAsFixed(1).replaceAll('.', ',')}k'
        : investidores.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      // Grade de indicadores.
      child: Row(
        children: [
          StatsBox(
            primaryText: data.totalStartupsMercado.toString(),
            secondaryText: 'Startups\ndisponíveis',
          ),
          const SizedBox(width: 12),
          StatsBox(
            primaryText: rentabilidadeStr,
            secondaryText: 'Rentabilidade\neste mês',
          ),
          const SizedBox(width: 12),
          StatsBox(
            primaryText: investidoresStr,
            secondaryText: 'Investidores\nativos',
          ),
        ],
      ),
    );
  }
}
