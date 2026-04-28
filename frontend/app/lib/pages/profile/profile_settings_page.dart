import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/profile/widgets/widgets.dart';

/// [ProfileSettingsPage] é a tela onde o usuário pode gerenciar sua conta.
/// 
/// Esta tela foi refatorada para utilizar widgets modulares, facilitando a manutenção
/// e mantendo o código limpo e bem comentado.
class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      
      // Barra superior com botão de voltar e título centralizado.
      appBar: _buildAppBar(context),
      
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEÇÃO: DADOS DA CONTA ---
            const SettingsSectionTitle(title: 'Dados da Conta'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Alterar Nome',
                  onTap: () => _simularAcao(context, 'Alterar Nome'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Alterar E-mail',
                  onTap: () => _simularAcao(context, 'Alterar E-mail'),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Alterar Senha',
                  onTap: () => _simularAcao(context, 'Alterar Senha'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // --- SEÇÃO: SEGURANÇA ---
            const SettingsSectionTitle(title: 'Segurança e Privacidade'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Deletar Conta',
                  isDestructive: true,
                  onTap: () => _mostrarConfirmacaoDelecao(context),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // --- OPÇÃO ADICIONAL DE VOLTAR ---
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
            
            // Rodapé com versão do app.
            const _RodapeVersao(),
          ],
        ),
      ),
    );
  }

  /// Constrói a AppBar personalizada para a tela de configurações.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Configurações',
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

  /// Exibe um alerta de confirmação antes de uma ação destrutiva.
  void _mostrarConfirmacaoDelecao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Deletar Conta?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Esta ação é irreversível e todos os seus dados de investimento serão perdidos permanentemente.',
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
              _simularAcao(context, 'Deletar Conta');
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

  /// Helper para exibir feedback visual de ações em desenvolvimento.
  void _simularAcao(BuildContext context, String acao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ação "$acao" será implementada em breve.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Widget privado para exibir a versão no rodapé.
class _RodapeVersao extends StatelessWidget {
  const _RodapeVersao();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Versão 1.0.0',
        style: GoogleFonts.inter(
          color: const Color(0xFFAAAAAA),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
