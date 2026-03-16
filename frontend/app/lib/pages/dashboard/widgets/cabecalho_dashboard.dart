/// --- Widget de Cabeçalho do Dashboard ---
/// Fase 1 etapa 2: Barra superior com avatar do usuário, nome e ícone de notificação.

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';


// --- CÓDIGO ---

/// Eu represento a barra de cabeçalho superior do dashboard.
class CabecalhoDashboard extends StatelessWidget {

  // construtor
  const CabecalhoDashboard({super.key});


  /// Eu construo a linha do cabeçalho com avatar do usuário, nome e sino de notificação.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [

          // avatar do usuário
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'U',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // nome do usuário
          const Text(
            'Renata',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const Spacer(),

          // sino de notificações
          IconButton(
            onPressed: () {
              // TODO: navegar para notificações
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
              size: 24,
            ),
          ),

        ],
      ),
    );
  }
}
