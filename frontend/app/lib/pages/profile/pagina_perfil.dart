import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/profile/controllers/perfil_controller.dart';
import 'package:mesclainvest/pages/profile/widgets/widgets.dart';

/// View principal da tela de Perfil.
class PaginaPerfil extends StatefulWidget {
  const PaginaPerfil({super.key});

  @override
  State<PaginaPerfil> createState() => _PaginaPerfilState();
}

class _PaginaPerfilState extends State<PaginaPerfil> {
  // Controlador de estado e lógica.
  final PerfilController _controller = PerfilController();

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento dos dados ao abrir a tela.
    _controller.inicializar();
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
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8), // Background slightly lighter
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : Column(
                    children: [
                      const CabecalhoPerfil(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              InfoUsuario(controller: _controller),
                              CartaoEstatisticas(controller: _controller),
                              
                              // Section for 2FA
                              _buildSectionContainer(
                                child: TileAcaoPerfil(
                                  icon: Icons.shield_outlined,
                                  title: 'Autenticação 2FA',
                                  subtitle: 'Proteção extra para sua conta',
                                  showArrow: false,
                                  trailing: SizedBox(
                                    height: 32,
                                    width: 52,
                                    child: Switch(
                                      value: _controller.autenticacao2FA,
                                      onChanged: (v) => _controller.toggle2FA(v),
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: Colors.black,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: const Color(0xFFCFCFCF),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Section for main actions
                              _buildSectionContainer(
                                child: Column(
                                  children: [
                                    const TileAcaoPerfil(
                                      icon: Icons.account_balance_wallet_outlined,
                                      title: 'Minha Carteira',
                                    ),
                                    _buildDivider(),
                                    const TileAcaoPerfil(
                                      icon: Icons.settings_outlined,
                                      title: 'Configurações',
                                    ),
                                    _buildDivider(),
                                    const TileAcaoPerfil(
                                      icon: Icons.help_outline,
                                      title: 'Ajuda & Suporte',
                                    ),
                                    _buildDivider(),
                                    TileAcaoPerfil(
                                      icon: Icons.dark_mode_outlined,
                                      title: 'Modo Escuro / Claro',
                                      showArrow: false,
                                      trailing: SizedBox(
                                        height: 32,
                                        width: 52,
                                        child: Switch(
                                          value: _controller.modoEscuro,
                                          onChanged: (v) => _controller.toggleModoEscuro(v),
                                          activeThumbColor: Colors.white,
                                          activeTrackColor: Colors.black,
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor: const Color(0xFFCFCFCF),
                                        ),
                                      ),
                                    ),
                                    _buildDivider(),
                                    const TileAcaoPerfil(
                                      icon: Icons.star_outline,
                                      title: 'Startups Favoritas',
                                    ),
                                  ],
                                ),
                              ),
                              
                              BotaoSair(controller: _controller),
                            ],
                          ),
                        ),
                      ),
                      const NavegacaoInferiorMock(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Constrói um container padrão para as seções da tela com bordas arredondadas e borda leve.
  Widget _buildSectionContainer({
    required Widget child,
  }) {
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

  /// Cria um divisor visual fino entre os itens da lista.
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 64),
      height: 1,
      color: const Color(0xFFF2F2F2),
    );
  }
}
