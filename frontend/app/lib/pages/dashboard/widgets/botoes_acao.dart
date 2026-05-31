/*
 * Widgets para os botões de ação do Dashboard (Depositar, Comprar, Vender, Extrato).
 *
 * Este arquivo reúne a barra de atalhos rápidos do usuário na tela principal.
 * Ele provê botões funcionais para:
 * 1. Carteira: Abre o painel de custódia consolidada.
 * 2. Depositar: Abre um modal interativo de dois passos (Digitação -> Confirmação) para injetar saldo na conta fictícia.
 * 3. Comprar: Redireciona para o catálogo de startups disponíveis para receber aportes.
 * 4. Vender: Abre o mercado secundário descentralizado (Balcão P2P) para cadastrar ordens de venda.
 * 5. Extrato: Exibe o histórico recente de depósitos, compras e vendas utilizando consultas assíncronas.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

library;

/*
 * IMPORTS
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/services/extrato_pdf.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

/*
 * HELPERS
 */

/// Formata a entrada do usuário em tempo real como moeda brasileira (R$ X.XXX,XX).
/// Os dígitos entram da direita para a esquerda (estilo caixa registradora - centavos primeiro).
/// Utilizado para mascarar a digitação do valor de depósito.
class _CurrencyInputFormatter extends TextInputFormatter {
  final _fmt = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extrai apenas os dígitos
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Trata os dígitos como centavos (divide por 100)
    final cents = int.parse(digits);
    if (cents > 10000000) return oldValue; // bloqueia acima de R$ 100.000,00

    final value = cents / 100.0;
    final formatted = _fmt.format(value).trim();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/*
 * CODE
 */

/// Widget principal que agrupa os botões de atalho da dashboard em uma linha horizontal rolável/ajustável.
class BotoesAcao extends StatelessWidget {
  /// Controlador do Dashboard para disparar ações financeiras globais e ler estados de saldo.
  final DashboardController controller;

  /// Construtor injetando o controller.
  const BotoesAcao({super.key, required this.controller});

  /**
   * MÉTODOS PRIVADOS
   */

  /// Abre o pop-up de depósito (Simulação bancária de entrada de recursos na carteira).
  /// Possui fluxo de dois passos usando um [StatefulBuilder] interno para gerenciar a transição:
  /// - Passo 1: Digitação do valor com máscara de moeda e validações de teto (limite R$ 100k).
  /// - Passo 2: Tela de confirmação e processamento de chamada assíncrona ao backend com feedback visual.
  void _mostrarDialogoDeposito(BuildContext context) {
    final TextEditingController valorController = TextEditingController();
    bool isProcessando = false;
    bool mostrarConfirmacao = false;
    double? valorFinal;

    showDialog(
      context: context,
      barrierDismissible: !isProcessando,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final bool noPassoConfirmacao = mostrarConfirmacao;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              noPassoConfirmacao ? 'Confirmar Depósito' : 'Depositar Saldo',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: noPassoConfirmacao
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Você confirma o depósito de:'),
                        const SizedBox(height: 12),
                        Text(
                          NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          ).format(valorFinal),
                          style: moneyStyle(
                            fontSize: 28,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Este valor será adicionado instantaneamente à sua carteira simulada.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Digite o valor que deseja simular o depósito em sua conta MesclaInvest.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: valorController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          inputFormatters: [_CurrencyInputFormatter()],
                          decoration: InputDecoration(
                            labelText: 'Valor (R\$)',
                            prefixText: 'R\$ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.textPrimary(context),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            actions: [
              AppButton(
                label: 'Cancelar',
                variant: AppButtonVariant.text,
                size: AppButtonSize.small,
                fullWidth: false,
                onPressed: isProcessando ? null : () => Navigator.pop(context),
              ),
              AppButton(
                label: noPassoConfirmacao ? 'Confirmar' : 'Continuar',
                size: AppButtonSize.small,
                fullWidth: false,
                isLoading: isProcessando,
                onPressed: isProcessando ? null : () async {
                  if (isProcessando) return;
                  if (!noPassoConfirmacao) {
                    final raw = valorController.text
                        .replaceAll('.', '')
                        .replaceAll(',', '.');
                    final double? parsedValue = double.tryParse(raw);

                    if (parsedValue != null && parsedValue > 0) {
                      if (parsedValue > 100000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'O valor máximo para depósito é R\$ 100.000,00.',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      setState(() {
                        valorFinal = parsedValue;
                        mostrarConfirmacao = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Por favor, insira um valor válido.'),
                          backgroundColor: Colors.orange.shade700,
                        ),
                      );
                    }
                  } else {
                    setState(() => isProcessando = true);
                    try {
                      await controller.deposit(valorFinal!);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Depósito de R\$ ${valorFinal!.toStringAsFixed(2)} realizado com sucesso!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() => isProcessando = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Abre o pop-up de extrato contendo as movimentações recentes do usuário.
  /// Consome a lista assíncrona obtida pelo controller através de um [FutureBuilder].
  /// Trata estados de carregamento (shimmer/progress), erro na comunicação e lista vazia de forma amigável.
  String _formatMes(int month, int year) {
    final mes = DateFormat('MMMM', 'pt_BR').format(DateTime(year, month));
    return '${mes[0].toUpperCase()}${mes.substring(1)} $year';
  }

  void _mostrarDialogoExtrato(BuildContext context) {
    final now = DateTime.now();
    var selectedMonth = now.month;
    var selectedYear  = now.year;
    Future<List<TransactionModel>>? txFuture;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            txFuture ??= controller.getTransactions(
              month: selectedMonth,
              year:  selectedYear,
            );

            void goToMonth(int m, int y) {
              setDialogState(() {
                selectedMonth = m;
                selectedYear  = y;
                txFuture = controller.getTransactions(month: m, year: y);
              });
            }

            void prevMonth() {
              if (selectedMonth == 1) {
                goToMonth(12, selectedYear - 1);
              } else {
                goToMonth(selectedMonth - 1, selectedYear);
              }
            }

            void nextMonth() {
              if (selectedMonth == 12) {
                goToMonth(1, selectedYear + 1);
              } else {
                goToMonth(selectedMonth + 1, selectedYear);
              }
            }

            final isCurrentMonth = selectedMonth == now.month && selectedYear == now.year;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.receipt_long_outlined, color: AppColors.textPrimary(ctx)),
                  const SizedBox(width: 10),
                  const Text('Extrato', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  FutureBuilder<List<TransactionModel>>(
                    future: txFuture,
                    builder: (ctx2, snap) {
                      final txs = snap.data ?? [];
                      return IconButton(
                        tooltip: 'Exportar PDF',
                        icon: Icon(Icons.picture_as_pdf_outlined, color: AppColors.textPrimary(ctx)),
                        onPressed: txs.isEmpty ? null : () => exportExtratoPdf(
                          transactions: txs,
                          userName: AppState.instance.profile?.fullName ?? 'Usuário',
                          month: selectedMonth,
                          year:  selectedYear,
                        ),
                      );
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 440,
                child: Column(
                  children: [
                    // --- Seletor de mês ---
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted(ctx),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: prevMonth,
                            color: AppColors.textSecondary(ctx),
                          ),
                          Text(
                            _formatMes(selectedMonth, selectedYear),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(ctx),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: isCurrentMonth ? null : nextMonth,
                            color: isCurrentMonth
                                ? AppColors.textMuted(ctx)
                                : AppColors.textSecondary(ctx),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- Lista de transações ---
                    Expanded(
                      child: FutureBuilder<List<TransactionModel>>(
                        future: txFuture,
                        builder: (ctx2, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(color: AppColors.textPrimary(ctx)),
                            );
                          }
                          if (snapshot.hasError) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_off_outlined, size: 48, color: Colors.red.shade200),
                                const SizedBox(height: 16),
                                const Text('Erro ao carregar o extrato.',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                const Text('Verifique sua conexão e tente novamente.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_toggle_off, size: 48, color: AppColors.textMuted(ctx)),
                                const SizedBox(height: 16),
                                Text('Nenhuma movimentação em ${_formatMes(selectedMonth, selectedYear)}.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textSecondary(ctx))),
                              ],
                            );
                          }
                          final transactions = snapshot.data!;
                          return ListView.separated(
                            itemCount: transactions.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final t = transactions[index];
                              final isPositive = t.type == 'deposit' || t.type == 'sell';
                              final color = isPositive ? Colors.green.shade700 : Colors.red.shade700;
                              final prefix = isPositive ? '+' : '-';
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(isPositive ? Icons.add : Icons.remove, color: color, size: 20),
                                ),
                                title: Text(t.description,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt),
                                    style: const TextStyle(fontSize: 12)),
                                trailing: Text(
                                  '$prefix ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(t.amount)}',
                                  style: moneyStyle(color: color),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                AppButton(
                  label: 'Fechar',
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.small,
                  fullWidth: false,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão: Depositar
          _BotaoAcaoItem(
            icon: Icons.add,
            label: 'Depositar',
            onTap: () => _mostrarDialogoDeposito(context),
          ),

          // Botão: Sacar (em breve)
          _BotaoAcaoItem(
            icon: Icons.arrow_circle_down_outlined,
            label: 'Sacar',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saques em breve! Esta funcionalidade está em desenvolvimento.'),
                duration: Duration(seconds: 3),
              ),
            ),
          ),

          // Botão: Comprar
          _BotaoAcaoItem(
            icon: Icons.trending_up,
            label: 'Comprar',
            onTap: () => context.go('/catalog'),
          ),

          // Botão: Vender
          // Pedro Henrique Medeiros dos Reis - 24801656 — routes to /balcao
          // (P2P market) so users can put up sell offers.
          _BotaoAcaoItem(
            icon: Icons.account_balance_outlined,
            label: 'Vender',
            onTap: () => context.go('/balcao'),
          ),

          // Botão: Extrato
          _BotaoAcaoItem(
            icon: Icons.receipt_long_outlined,
            label: 'Extrato',
            onTap: () => _mostrarDialogoExtrato(context),
          ),
        ],
      ),
    );
  }
}

/// Widget interno para representar cada item de ação individual com feedbacks visuais de foco e toque.
/// 
/// Todos os botões iniciam com cores discretas e mudam de cor dinamicamente quando focados
/// pelo ponteiro do mouse (no Desktop) ou pressionados (no Mobile/Web), gerando uma experiência interativa rica.
class _BotaoAcaoItem extends StatefulWidget {
  /// Ícone que ilustra a ação a ser executada.
  final IconData icon;
  
  /// Texto exibido logo abaixo do ícone.
  final String label;
  
  /// Callback de navegação ou abertura de diálogos disparado ao clicar no botão.
  final VoidCallback onTap;

  /// Construtor com propriedades obrigatórias.
  const _BotaoAcaoItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_BotaoAcaoItem> createState() => _BotaoAcaoItemState();
}

class _BotaoAcaoItemState extends State<_BotaoAcaoItem> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Hover (desktop/web): fica preto ao passar o mouse
      onEnter: (_) => setState(() => _isActive = true),
      onExit: (_) => setState(() => _isActive = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isActive = true),
        onTapUp: (_) => setState(() => _isActive = false),
        onTapCancel: () => setState(() => _isActive = false),
        child: Column(
          children: [
            // Círculo/Quadrado arredondado do ícone
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _isActive
                    ? AppColors.textPrimary(context)
                    : AppColors.surfaceMuted(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: _isActive
                    ? AppColors.surfaceColor(context)
                    : AppColors.textPrimary(context),
                size: 24,
              ),
            ),

            const SizedBox(height: 8),

            // Rótulo de texto abaixo do ícone
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 12,
                fontWeight: _isActive ? FontWeight.w600 : FontWeight.w500,
                color: _isActive
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context),
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}
