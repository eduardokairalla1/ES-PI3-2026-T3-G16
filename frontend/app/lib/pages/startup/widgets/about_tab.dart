/// Eduardo Kairalla - 24024241

/// Content of the "About" tab on the startup detail screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';


// --- WIDGET ---

class AboutTab extends StatelessWidget {

  final StartupModel startup;

  const AboutTab({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _sectionTitle('Sumário Executivo'),
          const SizedBox(height: 10),
          Text(
            startup.executiveSummary,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.65),
              height: 1.55,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _statCard(
                label: 'CAPITAL CAPTADO',
                value: NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                    .format(startup.capitalRaised),
                icon:  Icons.monetization_on_outlined,
                color: Colors.green,
              )),
              const SizedBox(width: 12),
              Expanded(child: _statCard(
                label: 'TOKENS EMITIDOS',
                value: NumberFormat.compact(locale: 'pt_BR')
                    .format(startup.totalTokens),
                icon:  Icons.token_outlined,
                color: Colors.blue,
              )),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle('Sobre o Projeto'),
          const SizedBox(height: 10),
          Text(
            startup.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.65),
              height: 1.55,
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle('Documentos'),
          const SizedBox(height: 10),
          _documentItem(
            icon:      Icons.picture_as_pdf_outlined,
            title:     'Plano de Negócios',
            subtitle:  'Em breve',
            available: false,
          ),

          const SizedBox(height: 32),

        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
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
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool available,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black54, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            available ? Icons.download_outlined : Icons.lock_outline,
            color: Colors.black38,
            size: 20,
          ),
        ],
      ),
    );
  }
}
