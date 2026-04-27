import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/profile/controllers/perfil_controller.dart';
import 'package:mesclainvest/pages/profile/widgets/widgets.dart';

/// [PaginaPerfil] é o componente principal da tela de perfil do usuário.
/// Ela utiliza um padrão de arquitetura baseada em Controller para separar a lógica da UI.
class PaginaPerfil extends StatefulWidget {
  const PaginaPerfil({super.key});

  @override
  State<PaginaPerfil> createState() => _PaginaPerfilState();
}

class _PaginaPerfilState extends State<PaginaPerfil> {
  // Inicializa o controlador que gerencia o estado e as ações da tela.
  final PerfilController _controller = PerfilController();

  @override
  void initState() {
    super.initState();
    // Ao iniciar a tela, solicitamos ao controlador que carregue os dados do perfil.
    _controller.inicializar();
  }

  @override
  void dispose() {
    // Importante limpar o controlador para evitar vazamentos de memória.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O AnimatedBuilder escuta as notificações do _controller (que é um ChangeNotifier).
    // Sempre que o controller chamar notifyListeners(), esta UI será reconstruída.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          // Define uma cor de fundo clara e moderna para destacar os cards brancos.
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            // Verifica se os dados ainda estão sendo carregados.
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : Column(
                    children: [
                      // Cabeçalho fixo no topo com o logo e nome do app.
                      const CabecalhoPerfil(),
                      
                      // O Expanded garante que a lista ocupe todo o espaço disponível restante.
                      Expanded(
                        child: SingleChildScrollView(
                          // BouncingScrollPhysics dá aquele efeito elástico agradável ao rolar (estilo iOS).
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Widget que exibe o Avatar, Nome e Email do usuário.
                              InfoUsuario(controller: _controller),
                              
                              // Painel com estatísticas rápidas (Investimentos, Valor Aplicado, etc).
                              CartaoEstatisticas(controller: _controller),
                              
                              // --- SEÇÃO DE SEGURANÇA (2FA) ---
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
                              
                              // --- SEÇÃO DE AÇÕES PRINCIPAIS ---
                              _buildSectionContainer(
                                child: Column(
                                  children: [
                                    const TileAcaoPerfil(
                                      icon: Icons.account_balance_wallet_outlined,
                                      title: 'Minha Carteira',
                                    ),
                                    _buildDivider(),
                                    TileAcaoPerfil(
                                      icon: Icons.settings_outlined,
                                      title: 'Configurações',
                                      onTap: () => context.push('/settings'),
                                    ),
                                    _buildDivider(),
                                    const TileAcaoPerfil(
                                      icon: Icons.help_outline,
                                      title: 'Ajuda & Suporte',
                                    ),
                                    _buildDivider(),
                                    // Item de menu com Switch para alternar o modo visual.
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
                              
                              // Botão de Logout posicionado ao final da lista.
                              BotaoSair(controller: _controller),
                            ],
                          ),
                        ),
                      ),
                      
                      // Barra de navegação inferior (Simulada).
                      const NavegacaoInferiorMock(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Helper para construir containers padronizados com cantos arredondados (estilo iOS/Premium).
  /// [child] é o conteúdo que ficará dentro do container.
  Widget _buildSectionContainer({
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Cantos bem arredondados conforme o design.
        border: Border.all(color: const Color(0xFFEBEBEB)), // Borda leve para definição.
      ),
      child: child,
    );
  }

  /// Constrói um divisor fino que não ocupa a largura total, alinhando-se ao texto dos itens.
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 64), // Alinhado com o início do texto após o ícone.
      height: 1,
      color: const Color(0xFFF2F2F2),
    );
  }
}
