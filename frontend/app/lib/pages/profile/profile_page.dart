import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/profile/controllers/profile_controller.dart';
import 'package:mesclainvest/pages/profile/widgets/widgets.dart';

/// Tela principal de perfil do usuário.
///
/// Esta tela monta a estrutura visual do perfil e reage ao estado
/// do [ProfileController].
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// Controlador responsável por carregar e gerenciar o estado da tela.
  final ProfileController _controller = ProfileController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : Column(
                    children: [
                      const ProfileHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              ProfileUserInfo(controller: _controller),
                              ProfileStatsCard(controller: _controller),

                              // Bloco de segurança da conta.
                              _section(
                                child: ProfileActionTile(
                                  icon: Icons.shield_outlined,
                                  title: 'Autenticacao 2FA',
                                  subtitle: 'Protecao extra para sua conta',
                                  showArrow: false,
                                  trailing: SizedBox(
                                    height: 32,
                                    width: 52,
                                    child: Switch(
                                      value: _controller.twoFactorEnabled,
                                      onChanged: _controller.setTwoFactor,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: Colors.black,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: const Color(0xFFCFCFCF),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Bloco principal de ações do perfil.
                              _section(
                                child: Column(
                                  children: [
                                    const ProfileActionTile(
                                      icon: Icons.account_balance_wallet_outlined,
                                      title: 'Minha Carteira',
                                    ),
                                    _divider(),
                                    const ProfileSettingsButton(),
                                    _divider(),
                                    const ProfileHelpButton(),
                                    _divider(),
                                    ProfileActionTile(
                                      icon: Icons.dark_mode_outlined,
                                      title: 'Modo Escuro',
                                      showArrow: false,
                                      trailing: SizedBox(
                                        height: 32,
                                        width: 52,
                                        child: Switch(
                                          value: _controller.darkModeEnabled,
                                          onChanged: _controller.setDarkMode,
                                          activeThumbColor: Colors.white,
                                          activeTrackColor: Colors.black,
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor: const Color(0xFFCFCFCF),
                                        ),
                                      ),
                                    ),
                                    _divider(),
                                    const ProfileActionTile(
                                      icon: Icons.star_outline,
                                      title: 'Startups Favoritas',
                                    ),
                                  ],
                                ),
                              ),
                              ProfileLogoutButton(controller: _controller),
                            ],
                          ),
                        ),
                      ),
                      const ProfileBottomNavMock(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Container visual padrão usado para agrupar seções da tela.
  Widget _section({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: child,
    );
  }

  /// Divisor horizontal entre itens de ação.
  Widget _divider() {
    return Container(
      margin: const EdgeInsets.only(left: 64),
      height: 1,
      color: const Color(0xFFF2F2F2),
    );
  }
}

