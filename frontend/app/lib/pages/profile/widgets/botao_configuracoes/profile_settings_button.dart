import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/profile/widgets/profile_action_tile.dart';

/// Botão de acesso à tela de configurações.
class ProfileSettingsButton extends StatelessWidget {
  const ProfileSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileActionTile(
      icon: Icons.settings_outlined,
      title: 'Configuracoes',
      onTap: () => context.push('/settings'),
    );
  }
}

