// --- Notifications sheet ---
//
// Lightweight bottom sheet that turns recent account activity into actionable
// notification rows for the dashboard and balcão headers.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- TYPES ---

/// Display model for one actionable notification row.
class AppNotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String route;

  const AppNotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

// --- CODE ---

/// Opens the account notifications sheet.
Future<void> showAppNotificationsSheet({
  required BuildContext context,
  required Future<List<TransactionModel>> Function() loadTransactions,
  DashboardData? data,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.surfaceColor(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return _NotificationsContent(
        data: data,
        loadTransactions: loadTransactions,
      );
    },
  );
}

class _NotificationsContent extends StatelessWidget {
  final DashboardData? data;
  final Future<List<TransactionModel>> Function() loadTransactions;

  const _NotificationsContent({
    required this.data,
    required this.loadTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionModel>>(
      future: loadTransactions(),
      builder: (context, snapshot) {
        final items = _buildItems(snapshot.data ?? []);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notificacoes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Atividades recentes da sua conta',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                _EmptyNotifications()
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: AppColors.borderSoft(context),
                    ),
                    itemBuilder: (context, index) {
                      return _NotificationTile(item: items[index]);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<AppNotificationItem> _buildItems(List<TransactionModel> transactions) {
    final items = <AppNotificationItem>[];

    for (final tx in transactions.take(4)) {
      items.add(_fromTransaction(tx));
    }

    final investimentos = data?.investimentos.length ?? 0;
    if (investimentos > 0) {
      items.add(
        AppNotificationItem(
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.indigo,
          title: '$investimentos investimento(s) ativo(s)',
          subtitle: 'Acompanhe sua carteira e a evolucao dos tokens.',
          route: '/carteira',
        ),
      );
    }

    final favoritas = data?.favoriteIds.length ?? 0;
    if (favoritas > 0) {
      items.add(
        AppNotificationItem(
          icon: Icons.star_outline,
          color: Colors.amber.shade700,
          title: '$favoritas startup(s) favorita(s)',
          subtitle: 'Veja oportunidades das startups que voce acompanha.',
          route: '/catalog',
        ),
      );
    }

    return items.take(6).toList();
  }

  AppNotificationItem _fromTransaction(TransactionModel tx) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final amount = formatter.format(tx.amount);

    if (tx.type == 'deposit') {
      return AppNotificationItem(
        icon: Icons.south_west,
        color: Colors.green.shade700,
        title: 'Deposito confirmado',
        subtitle: '$amount entrou no seu saldo disponivel.',
        route: '/carteira',
      );
    }

    if (tx.type == 'buy') {
      return AppNotificationItem(
        icon: Icons.shopping_bag_outlined,
        color: Colors.blue.shade700,
        title: 'Compra registrada',
        subtitle: tx.description,
        route: '/carteira',
      );
    }

    if (tx.type == 'sell') {
      return AppNotificationItem(
        icon: Icons.sell_outlined,
        color: Colors.purple.shade700,
        title: 'Venda registrada',
        subtitle: tx.description,
        route: '/balcao',
      );
    }

    return AppNotificationItem(
      icon: Icons.receipt_long_outlined,
      color: Colors.blueGrey,
      title: 'Movimentacao registrada',
      subtitle: tx.description,
      route: '/carteira',
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: item.color.withValues(alpha: 0.12),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: Text(
        item.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
      onTap: () {
        Navigator.of(context).pop();
        context.go(item.route);
      },
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.notifications_none,
              size: 42,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 10),
            Text(
              'Nada novo por enquanto.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
