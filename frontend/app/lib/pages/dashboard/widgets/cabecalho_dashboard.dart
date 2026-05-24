/*
 * Widget de cabeçalho do Dashboard, exibindo informações do perfil do usuário.
 *
 * Renderiza o cabeçalho superior da página principal, contendo o avatar do investidor,
 * o nome completo de perfil e o sino de alertas/notificações com badge indicador.
 * Sincroniza-se com o singleton global [AppState] para refletir instantaneamente
 * alterações de foto ou nome feitas na tela de Perfil.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

library;

/*
 * IMPORTS
 */

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';

/*
 * CODE
 */

/// Barra superior com dados do usuário (Avatar e Nome) e botão de notificações.
/// Reage reativamente às atualizações do perfil através do controlador de estado.
class CabecalhoDashboard extends StatelessWidget {
  /// Controlador do Dashboard fornecendo os dados e fluxo da página principal.
  final DashboardController controller;

  /// Construtor contendo a injeção do controller associado.
  const CabecalhoDashboard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Busca dados atualizados do perfil no singleton global (persistência temporária em RAM)
    final profile = AppState.instance.profile;
    
    // Fallback inteligente: se o perfil global estiver nulo (ex: refresh na página web),
    // tenta usar o nome retornado pela chamada do Dashboard no backend. Senão, mostra 'Usuário'.
    final userName = profile?.fullName ?? controller.data?.nomeUsuario ?? 'Usuário';
    
    // Obtém a primeira letra do nome do usuário para compor o avatar textual caso não haja foto definida
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final photoUrl = profile?.photoUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
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
            // --- Avatar do Usuário (clicável → abre perfil) ---
            GestureDetector(
              onTap: () => context.go('/profile'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary(context),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _initial(initial),
                        )
                      : _initial(initial),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // --- Nome do Usuário ---
            Expanded(
              child: Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),

            // --- Ícone de Notificações ---
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary(context),
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
    return Builder(
      builder: (context) => Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.surfaceColor(context),
          ),
        ),
      ),
    );
  }
}
