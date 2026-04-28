import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/widgets/widgets.dart';

/// Tela de configurações da conta do usuário.
class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionTitle(title: 'Dados da Conta'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Alterar Nome',
                  onTap: () => _showPendingAction(context, 'Alterar Nome'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Alterar E-mail',
                  onTap: () => _showPendingAction(context, 'Alterar E-mail'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Alterar Senha',
                  onTap: () => _showPendingAction(context, 'Alterar Senha'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const SettingsSectionTitle(title: 'Seguranca e Privacidade'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Deletar Conta',
                  isDestructive: true,
                  onTap: () => _showDeleteConfirmation(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.arrow_back_rounded,
                  title: 'Voltar para o Perfil',
                  onTap: () => context.pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _AppVersionFooter(),
          ],
        ),
      ),
    );
  }

  /// AppBar padrão das telas internas de perfil.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Configuracoes',
        style: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFEEEEEE), height: 1),
      ),
    );
  }

  /// Confirmação para ação destrutiva de exclusão de conta.
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Deletar Conta?', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text(
          'Esta acao e irreversivel e todos os seus dados de investimento serao perdidos permanentemente.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showPendingAction(context, 'Deletar Conta');
            },
            child: Text(
              'Deletar',
              style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// Feedback para ações ainda não implementadas.
  void _showPendingAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Acao "$action" sera implementada em breve.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Rodapé de versão do app.
class _AppVersionFooter extends StatelessWidget {
  const _AppVersionFooter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Versao 1.0.0',
        style: GoogleFonts.inter(
          color: const Color(0xFFAAAAAA),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

