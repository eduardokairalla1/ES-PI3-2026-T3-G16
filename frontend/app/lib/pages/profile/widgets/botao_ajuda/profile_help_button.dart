import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/profile/widgets/profile_action_tile.dart';

/// Botão de acesso à tela de ajuda e suporte.
class ProfileHelpButton extends StatelessWidget {
  const ProfileHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileActionTile(
      icon: Icons.help_outline,
      title: 'Ajuda e Suporte',
      onTap: () => context.push('/support'),
    );
  }
}

