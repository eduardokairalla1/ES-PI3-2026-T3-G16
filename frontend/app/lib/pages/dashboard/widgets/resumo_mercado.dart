import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/stats_box.dart';

/// Fase 4: Seção de Resumo do Mercado (KPIs)
class ResumoMercado extends StatelessWidget {

  const ResumoMercado({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      // Renderizando explicitamente os dois primeiros cards (Task 13)
      child: const Row(
        children: [
          StatsBox(
            primaryText: '99',
            secondaryText: 'Startups\ndisponíveis',
          ),
          SizedBox(width: 12),
          StatsBox(
            primaryText: '+9,9%',
            secondaryText: 'Rentabilidade\neste mês',
          ),
        ],
      ),
    );
  }
}
