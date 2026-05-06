/**
 * Widget de exibição das startups do ecossistema no Dashboard.
 * Inclui filtros dinâmicos por estágio (Novas, Operando, Favoritas) e listagem de cards.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * IMPORTS
 */
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/catalog/widgets/startup_card.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/widgets/resumo_mercado.dart';


/**
 * CODE
 */

/// Seção principal que exibe o catálogo resumido de startups e filtros de navegação.
class StartupsEcossistema extends StatelessWidget {
  
  // Atributos
  final DashboardController controller;

  // Construtor
  const StartupsEcossistema({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // --- Cabeçalho da Seção ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Startups do ecossistema',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              // Botão para ver o catálogo completo
              GestureDetector(
                onTap: () => context.push('/catalog'),
                child: Row(
                  children: [
                    Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.add, size: 16, color: Colors.blue.shade700),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- Barra de Filtros (Chips Horizontais) ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(
                label: 'Todas',
                isSelected: controller.selectedStartupFilter == null,
                onTap: () => controller.filterStartups(null),
              ),
              _FilterChip(
                label: 'Novas',
                isSelected: controller.selectedStartupFilter == 'new',
                onTap: () => controller.filterStartups('new'),
              ),
              _FilterChip(
                label: 'Operando',
                isSelected: controller.selectedStartupFilter == 'operating',
                onTap: () => controller.filterStartups('operating'),
              ),
              _FilterChip(
                label: 'Favoritas',
                isSelected: controller.selectedStartupFilter == 'Favoritas',
                onTap: () => controller.filterStartups('Favoritas'),
                icon: Icons.favorite,
                iconColor: Colors.red.shade400,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // --- Widgets de Resumo do Mercado (Injetado condicionalmente) ---
        if (controller.data != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ResumoMercado(controller: controller),
          ),
          const SizedBox(height: 16),
        ],

        // --- Lista de Startups Filtradas ou Estado Vazio ---
        if (controller.filteredStartups.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.business_center_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma startup encontrada.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          // Exibe apenas as 3 primeiras startups no dashboard (resumo)
          ...controller.filteredStartups.take(3).map((startup) => StartupCard(
                startup: startup,
                isFavorite: controller.isFavorite(startup.id),
                onFavoriteTap: () => controller.toggleFavorite(startup.id),
              )),
              
        const SizedBox(height: 16),
      ],
    );
  }
}



/// Widget interno para representar cada chip de filtro individual.
class _FilterChip extends StatelessWidget {
  
  // Atributos
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  // Construtor
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon, 
                size: 14, 
                color: isSelected ? Colors.white : (iconColor ?? Colors.grey.shade600),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
