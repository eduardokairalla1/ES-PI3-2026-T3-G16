import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/widgets/stats_box.dart';

/// Fase 4: Seção de Resumo do Mercado (KPIs)
class ResumoMercado extends StatelessWidget {

  const ResumoMercado({super.key});

  @override
  Widget build(BuildContext context) {
    // Retornamos apenas a estrutura de encapsulamento vazia
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      // os os `StatsBox` aqui dentro
      child: const SizedBox.shrink(),
    );
  }
}
