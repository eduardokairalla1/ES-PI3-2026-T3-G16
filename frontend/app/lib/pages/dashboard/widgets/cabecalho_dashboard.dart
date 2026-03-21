/// Cabeçalho com informações do usuário e notificações.

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';

/// Barra superior com dados do usuário e notificações.
class CabecalhoDashboard extends StatelessWidget {
  final DashboardController controller;
  
  const CabecalhoDashboard({super.key, required this.controller});


  @override
  Widget build(BuildContext context) {
    final nomeUsuario = controller.data?.nomeUsuario ?? 'Usuário';
    final inicial = nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [

          // Avatar.
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                inicial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Nome.
          Text(
            nomeUsuario,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const Spacer(),

          // Notificações.
          Stack(
            children: [

              // Ícone.
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

              // Alerta de notificação ativa.
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }
}
