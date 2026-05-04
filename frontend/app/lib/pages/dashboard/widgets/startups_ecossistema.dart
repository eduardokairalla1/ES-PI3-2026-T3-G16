import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/widgets/resumo_mercado.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';

final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 4);

class StartupsEcossistema extends StatelessWidget {

  final DashboardController controller;

  const StartupsEcossistema({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final filtered = controller.filteredStartups;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'STARTUPS DISPONÍVEIS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF888888),
                letterSpacing: 0.5,
              ),
            ),
          ),

          ResumoMercado(controller: controller),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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

          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.business_center_outlined, size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma startup encontrada.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filtered.take(4).map((s) => _StartupRow(
                  startup: s,
                  isFavorite: controller.isFavorite(s.id),
                  onFavoriteTap: () => controller.toggleFavorite(s.id),
                )),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: GestureDetector(
              onTap: () => context.go('/catalog'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Ver mais',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}


class _StartupRow extends StatelessWidget {

  final StartupModel startup;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _StartupRow({
    required this.startup,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/startup/${startup.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [

            _Logo(url: startup.logoUrl, name: startup.name),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                startup.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currencyFmt.format(startup.tokenPrice),
                  style: moneyStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                if (startup.changePercent != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${startup.changePercent! >= 0 ? '+' : ''}${startup.changePercent!.toStringAsFixed(2)}%',
                    style: moneyStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: startup.changePercent! >= 0
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(width: 4),

            IconButton(
              onPressed: onFavoriteTap,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey.shade400,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),

          ],
        ),
      ),
    );
  }
}


class _FilterChip extends StatelessWidget {

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
              Icon(icon, size: 13, color: isSelected ? Colors.white : (iconColor ?? Colors.grey.shade600)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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


class _Logo extends StatelessWidget {

  final String url;
  final String name;

  const _Logo({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 17,
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
