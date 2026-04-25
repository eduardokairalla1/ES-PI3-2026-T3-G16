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
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : Column(
                    children: [
                      // Cabeçalho superior
                      const CabecalhoPerfil(),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Avatar e informações básicas
                              InfoUsuario(controller: _controller),

                              // Resumo de investimentos e favoritas
                              CartaoEstatisticas(controller: _controller),
                              
                              // Configuração de segurança
                              _buildSectionContainer(
                                child: TileAcaoPerfil(
                                  icon: Icons.shield_outlined,
                                  title: 'Autenticação 2FA',
                                  subtitle: 'Proteção extra para sua conta',
                                  showArrow: false,
                                  trailing: Switch(
                                    value: _controller.autenticacao2FA,
                                    onChanged: (v) => _controller.toggle2FA(v),
                                    activeColor: Colors.black,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Opções gerais do menu
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
                                      trailing: Switch(
                                        value: _controller.modoEscuro,
                                        onChanged: (v) => _controller.toggleModoEscuro(v),
                                        activeColor: Colors.black,
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
                              
                              // Botão para encerrar sessão
                              BotaoSair(controller: _controller),
                            ],
                          ),
                        ),
                      ),

                      // Barra de navegação inferior (Mock)
                      const NavegacaoInferiorMock(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Constrói um container padrão para as seções da tela.
  Widget _buildSectionContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: child,
      ),
    );
  }

  /// Cria um divisor visual entre os itens da lista.
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Colors.grey[100],
    );
  }
}
