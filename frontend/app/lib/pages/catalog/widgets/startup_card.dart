/// Eduardo Kairalla - 24024241

/// Card widget for a startup in the catalog listing.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';


// --- HELPERS ---

final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

Color _stageColor(String stage) => switch (stage) {
  'new'       => const Color(0xFF1565C0),
  'operating' => const Color(0xFF2E7D32),
  'expanding' => const Color(0xFF6A1B9A),
  _           => Colors.black,
};


// --- WIDGET ---

class StartupCard extends StatelessWidget {

  final StartupModel startup;

  const StartupCard({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    final stageColor = _stageColor(startup.stage);

    return GestureDetector(
      onTap: () => context.push('/startup/${startup.id}'),
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

            // --- logo + name + stage ---
            Row(
              children: [
                _Logo(url: startup.logoUrl, name: startup.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startup.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        startup.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    startup.stageLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: stageColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 14),

            // --- token price + capital raised ---
            Row(
              children: [
                _Stat(
                  label: 'Preço do token',
                  value: NumberFormat.currency(
                    locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2,
                  ).format(startup.tokenPrice),
                ),
                const SizedBox(width: 24),
                _Stat(
                  label: 'Capital captado',
                  value: _currencyFmt.format(startup.capitalRaised),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFAAAAAA)),
              ],
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
      width: 52,
      height: 52,
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
                fontSize: 20,
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
