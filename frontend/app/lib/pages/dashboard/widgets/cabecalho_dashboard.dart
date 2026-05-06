/**
 * Widget de cabeçalho do Dashboard, exibindo informações do perfil do usuário.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * IMPORTS
 */
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';


/**
 * CODE
 */

/// Barra superior com dados do usuário (Avatar e Nome) e botão de notificações.
class CabecalhoDashboard extends StatelessWidget {
  
  // Construtor
  const CabecalhoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Busca dados do perfil global
    final profile    = AppState.instance.profile;
    final userName   = profile?.fullName ?? 'Usuário';
    final initial    = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final photoUrl   = profile?.photoUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- Avatar do Usuário ---
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: photoUrl != null
                  ? Image.network(
                      photoUrl, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _initial(initial),
                    )
                  : _initial(initial),
            ),
            const SizedBox(width: 12),
            
            // --- Nome do Usuário ---
            Text(
              userName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            
            // --- Ícone de Notificações ---
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
                // Badge de notificação (ponto vermelho)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 7,
                    height: 7,
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
      ),
    );
  }


  /**
   * MÉTODOS PRIVADOS
   */

  /// Retorna o widget com a inicial do nome caso não haja foto.
  Widget _initial(String letter) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
