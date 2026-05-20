// --- Deposit prompt card ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Shown on the dashboard when the user has zero balance — a friendly nudge
// to deposit something so they can start using the app.
//
// Tapping the button opens a simple deposit dialog right here (this file is
// self-contained so the card can be reused without depending on the action
// row that lives in botoes_acao.dart).

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- HELPERS ---

/// I format raw digits into BRL currency as the user types
/// (cashier-style entry — newest digit goes into the cents).
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

/// Friendly nudge shown on the dashboard when the wallet balance is zero.
///
/// Renders a card with a wallet icon, a short pitch and a "Depositar" CTA
/// that opens [showDepositDialog]. The card delegates the actual deposit
/// call to the same [DashboardController] used by the rest of the dashboard
/// so the balance refreshes everywhere once the deposit completes.
class DepositPromptCard extends StatelessWidget {
  /// Controller that owns the user's wallet state and performs the deposit.
  final DashboardController controller;

  /// Builds the prompt card bound to [controller].
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

/// Opens the deposit dialog. Reusable from any page that has a way to credit
/// the wallet — pass the deposit action as [onDeposit].
///
/// The dialog shows a single BRL-formatted amount field (cashier-style input,
/// max R$ 100.000,00), calls [onDeposit] with the parsed value on submit and
/// shows a success or error snackbar afterwards.
///
/// [context]   a [BuildContext] under the active [Navigator] / [ScaffoldMessenger].
/// [onDeposit] invoked with the parsed amount when the user submits. Must
///   throw on failure so the dialog can display the error.
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
