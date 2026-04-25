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
          backgroundColor: const Color(0xFFF2F2F2),
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : Column(
                    children: [
                      const CabecalhoPerfil(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              InfoUsuario(controller: _controller),
                              CartaoEstatisticas(controller: _controller),
                              _buildSectionContainer(
                                margin: const EdgeInsets.symmetric(horizontal: 14),
                                child: TileAcaoPerfil(
                                  icon: Icons.shield_outlined,
                                  title: 'Autenticação 2FA',
                                  subtitle: 'Proteção extra para sua conta',
                                  showArrow: false,
                                  trailing: Switch(
                                    value: _controller.autenticacao2FA,
                                    onChanged: (v) => _controller.toggle2FA(v),
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: Colors.black,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: const Color(0xFFCFCFCF),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildSectionContainer(
                                margin: const EdgeInsets.symmetric(horizontal: 14),
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
                                      trailing: Switch(
                                        value: _controller.modoEscuro,
                                        onChanged: (v) => _controller.toggleModoEscuro(v),
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: Colors.black,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: const Color(0xFFCFCFCF),
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

  /// Constrói um container padrão para as seções da tela.
  Widget _buildSectionContainer({
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: child,
    );
  }

  /// Cria um divisor visual entre os itens da lista.
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 54,
      endIndent: 14,
      color: Color(0xFFECECEC),
    );
  }
}
