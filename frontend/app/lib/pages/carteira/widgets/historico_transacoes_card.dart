// --- Histórico de transações card ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Inline transaction list shown at the bottom of the carteira page. Mirrors
// the visual style of the extrato dialog already used on the dashboard, but
// renders as a regular card (not a modal) so the user can scroll through
// recent moves without opening a popup.
//
// The list is intentionally short (top N) to keep the page snappy. Tapping
// the "Ver tudo" header chip will eventually navigate to a dedicated extrato
// page — for now it's a no-op placeholder so the layout stays consistent.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- CONSTANTS ---

/// Maximum rows shown inline. Anything older lives in the (future) full
/// extrato page.
const int _kMaxRows = 6;

final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _dateFmt     = DateFormat('dd/MM/yyyy');

// --- WIDGET ---

/// Card with the "Histórico de Transações" title and the latest transactions
/// (deposits, buys, sells) of the user.
class HistoricoTransacoesCard extends StatefulWidget {
  /// Controller exposing [DashboardController.getTransactions].
  final DashboardController controller;

  /// Builds the card bound to [controller].
  const HistoricoTransacoesCard({super.key, required this.controller});

  @override
  State<HistoricoTransacoesCard> createState() => _HistoricoTransacoesCardState();
}

class _HistoricoTransacoesCardState extends State<HistoricoTransacoesCard> {
  late Future<List<TransactionModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color:        AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset:    const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size:  18,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Histórico de Transações',
                style: TextStyle(
                  fontSize:    15,
                  fontWeight:  FontWeight.w700,
                  color:       AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<TransactionModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child:  Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (snapshot.hasError) {
                return _ErrorRow(onRetry: () {
                  setState(() => _future = widget.controller.getTransactions());
                });
              }
              final list = snapshot.data ?? const <TransactionModel>[];
              if (list.isEmpty) return const _EmptyRow();

              final rows = list.take(_kMaxRows).toList();
              return Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    _TransactionRow(tx: rows[i]),
                    if (i < rows.length - 1)
                      Divider(height: 1, color: AppColors.borderSoft(context)),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- INTERNAL: ROWS ---

class _TransactionRow extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    // "Money in" = deposits and sells. Everything else (buys, withdrawals) is
    // money out, so we render with a red minus sign and a downward arrow.
    final isPositive = tx.type == 'deposit' || tx.type == 'sell';
    final color  = isPositive ? Colors.green.shade700 : Colors.red.shade700;
    final prefix = isPositive ? '+' : '-';
    final icon   = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size:  18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateFmt.format(tx.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color:    AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$prefix ${_currencyFmt.format(tx.amount)}',
            style: TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w800,
              color:      color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off,
              size:  40,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhuma movimentação por enquanto.',
              style: TextStyle(
                fontSize: 13,
                color:    AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRow({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size:  40,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar o histórico.',
              style: TextStyle(
                fontSize:  13,
                color:     Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
