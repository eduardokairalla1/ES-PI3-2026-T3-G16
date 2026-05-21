// --- Deposit prompt card / Card de Estímulo a Depósito ---
// Pedro Henrique Medeiros dos Reis - 24801656
// Alex Gabriel Soares Sousa - 24802449
//
// Este widget é exibido no Dashboard quando o usuário possui saldo disponível igual a zero.
// Funciona como um atalho visual amigável (nudge) sugerindo que o usuário realize um depósito
// simulado para poder usufruir das funcionalidades da plataforma, como compra de ativos
// e publicação de ofertas no Balcão (P2P).
//
// O clique no botão abre um modal de depósito autossuficiente (evitando acoplamentos externos
// desnecessários, permitindo sua fácil reutilização em outras partes do app).

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- FORMATADORES / AUXILIARES ---

/// Formatador de entrada que converte caracteres numéricos em tempo real
/// em representação monetária BRL (R$ X.XXX,XX) de forma regressiva
/// (estilo caixa registradora - os novos números entram nos centavos).
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
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final cents = int.parse(digits);
    if (cents > 10000000) return oldValue; // max R$ 100.000,00

    final value = cents / 100.0;
    final formatted = _fmt.format(value).trim();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// --- WIDGET ---

/// Card amigável exibido no dashboard quando a carteira do usuário está vazia (saldo zero).
///
/// Apresenta um ícone de carteira, um texto explicativo e um botão de ação "Depositar"
/// que abre o [showDepositDialog]. Este card delega a operação de depósito diretamente
/// para o [DashboardController] associado, garantindo que o saldo seja atualizado de forma
/// reativa em todos os componentes após a finalização da transação.
class DepositPromptCard extends StatelessWidget {
  /// Controller proprietário do estado financeiro da conta do usuário.
  final DashboardController controller;

  /// Inicializa o card de estímulo acoplado ao [controller].
  const DepositPromptCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // big wallet icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 28,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          // headline
          Text(
            'Deposite para começar a investir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          // explanation
          Text(
            'Adicione fundos à sua carteira para participar do mercado '
            'de startups e usar o balcão.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // CTA
          AppButton(
            label: 'Depositar',
            icon: Icons.add,
            onPressed: () => showDepositDialog(
              context: context,
              onDeposit: controller.deposit,
            ),
          ),
        ],
      ),
    );
  }
}

// --- PUBLIC DIALOG ---

/// Abre o diálogo/modal de depósito na tela atual de forma genérica e reusável.
///
/// Renderiza uma caixa de diálogo contendo um campo formatado para inserção de valores monetários.
/// Ao submeter, valida se o valor digitado é maior que zero, chama a função de callback
/// assíncrona [onDeposit], gerencia estados locais de processamento (para exibir indicadores de loading)
/// e notifica o usuário via Snackbars sobre o sucesso ou falha da simulação de depósito.
///
/// Parâmetros:
/// - [context]: O contexto da árvore de widgets sob o [Navigator] ativo.
/// - [onDeposit]: Callback disparado com o valor numérico convertido ao salvar. Deve disparar erro caso falhe.
Future<void> showDepositDialog({
  required BuildContext context,
  required Future<void> Function(double amount) onDeposit,
}) async {
  final valorController = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (dialogCtx, setState) {
        bool isProcessing = false;

        Future<void> submit() async {
          // parse the BRL-formatted text back into a double
          final raw = valorController.text
              .replaceAll('.', '')
              .replaceAll(',', '.');
          final parsed = double.tryParse(raw);

          if (parsed == null || parsed <= 0) {
            ScaffoldMessenger.of(dialogCtx).showSnackBar(
              const SnackBar(content: Text('Informe um valor válido.')),
            );
            return;
          }

          setState(() => isProcessing = true);
          try {
            await onDeposit(parsed);
            if (dialogCtx.mounted) {
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(dialogCtx).showSnackBar(
                SnackBar(
                  content: Text(
                    'Depósito de R\$ ${parsed.toStringAsFixed(2)} realizado!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            setState(() => isProcessing = false);
            if (dialogCtx.mounted) {
              ScaffoldMessenger.of(dialogCtx).showSnackBar(
                SnackBar(
                  content: Text('Erro: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Depositar saldo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quanto você quer adicionar à sua carteira?',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary(dialogCtx)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valorController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [_CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.textPrimary(dialogCtx), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
              fullWidth: false,
              onPressed: isProcessing ? null : () => Navigator.pop(dialogCtx),
            ),
            AppButton(
              label: 'Depositar',
              size: AppButtonSize.small,
              fullWidth: false,
              isLoading: isProcessing,
              onPressed: submit,
            ),
          ],
        );
      },
    ),
  );
}
