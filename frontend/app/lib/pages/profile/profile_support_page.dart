import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesclainvest/pages/profile/widgets/widgets.dart';

/// Tela dedicada para ajuda e suporte ao usuário.
class ProfileSupportPage extends StatelessWidget {
  const ProfileSupportPage({super.key});

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
            const SettingsSectionTitle(title: 'Canais de Suporte'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat com suporte',
                  onTap: () => _showPendingMessage(context, 'Chat com suporte'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.mail_outline,
                  title: 'Enviar e-mail',
                  onTap: () => _showPendingMessage(context, 'Enviar e-mail'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.call_outlined,
                  title: 'Contato telefonico',
                  onTap: () => _showPendingMessage(context, 'Contato telefonico'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const SettingsSectionTitle(title: 'Autoatendimento'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Central de ajuda',
                  onTap: () => _showPendingMessage(context, 'Central de ajuda'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Reportar problema',
                  onTap: () => _showPendingMessage(context, 'Reportar problema'),
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
          ],
        ),
      ),
    );
  }

  /// Cabeçalho da tela de suporte.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Ajuda e Suporte',
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

  /// Feedback para ações ainda em desenvolvimento.
  void _showPendingMessage(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Acao "$action" sera implementada em breve.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

