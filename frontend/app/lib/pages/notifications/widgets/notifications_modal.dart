// Pedro Henrique Medeiros dos Reis - 24801656
//
// Bottom-sheet showing the pending notifications. Tapping a tile clears
// the item and navigates; "Marcar como lido" clears everything at once.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/notifications/controllers/notifications_controller.dart';
import 'package:mesclainvest/pages/notifications/models/notification_model.dart';
import 'package:mesclainvest/pages/notifications/widgets/notification_tile.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

class NotificationsModal extends StatefulWidget {
  const NotificationsModal({super.key});

  /// Opens the modal as a draggable bottom-sheet.
  ///
  /// `useRootNavigator: true` anchors the sheet to the app's root Navigator
  /// so it renders on top of the bottom-nav shell — otherwise the nav bar
  /// would clip the bottom of the list.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsModal(),
    );
  }

  @override
  State<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends State<NotificationsModal> {
  final NotificationsController _controller = NotificationsController.instance;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize:     0.50,
      maxChildSize:     0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(context),
              _buildHeader(context),
              Divider(height: 1, color: AppColors.borderSoft(context)),
              Expanded(child: _buildBody(scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border(context),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hasItems = _controller.notifications.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
          child: Row(
            children: [
              Text(
                'Notificações',
                style: TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w800,
                  color:      AppColors.textPrimary(context),
                ),
              ),
              const Spacer(),
              if (hasItems)
                TextButton(
                  onPressed: _onMarkAllRead,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textPrimary(context),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text(
                    'Marcar como lido',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading && _controller.notifications.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (_controller.errorMessage != null && _controller.notifications.isEmpty) {
          return _buildError();
        }

        if (_controller.notifications.isEmpty) {
          return _buildEmpty();
        }

        return _buildList(scrollController, _controller.notifications);
      },
    );
  }

  Widget _buildList(ScrollController scrollController, List<NotificationModel> items) {
    final groups = _groupByDate(items);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: groups.length,
      itemBuilder: (context, sectionIdx) {
        final group = groups[sectionIdx];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
              child: Text(
                group.label,
                style: TextStyle(
                  fontSize:    11,
                  fontWeight:  FontWeight.w700,
                  letterSpacing: 0.6,
                  color:       AppColors.textMuted(context),
                ),
              ),
            ),
            for (final n in group.items)
              NotificationTile(
                notification: n,
                onTap: () => _onTapNotification(n),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size:  56,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Você está em dia!',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nenhuma notificação por aqui.',
              textAlign: TextAlign.center,
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              _controller.errorMessage ?? 'Erro ao carregar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.red.shade700),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _controller.load(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMarkAllRead() async {
    await _controller.clearAll();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _onTapNotification(NotificationModel n) async {
    // Capture the router before pop (the context becomes invalid afterwards).
    // Use go() instead of push() so shell-route tabs switch correctly.
    final route  = _routeFor(n);
    final router = GoRouter.of(context);

    await _controller.deleteOne(n.id);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (route != null) router.go(route);
  }

  String? _routeFor(NotificationModel n) {
    switch (n.type) {
      case NotificationType.orderExecuted:
      case NotificationType.orderCounterMatch:
        return '/balcao';
      case NotificationType.depositConfirmed:
        return '/carteira';
      case NotificationType.questionAnswered:
        return n.startupId != null ? '/startup/${n.startupId}' : null;
      case NotificationType.welcome:
      case NotificationType.unknown:
        return null;
    }
  }

  List<_NotificationGroup> _groupByDate(List<NotificationModel> items) {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo   = today.subtract(const Duration(days: 7));

    final hoje    = <NotificationModel>[];
    final ontem   = <NotificationModel>[];
    final semana  = <NotificationModel>[];
    final antigas = <NotificationModel>[];

    for (final n in items) {
      final whenDay = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (!whenDay.isBefore(today)) {
        hoje.add(n);
      } else if (!whenDay.isBefore(yesterday)) {
        ontem.add(n);
      } else if (!whenDay.isBefore(weekAgo)) {
        semana.add(n);
      } else {
        antigas.add(n);
      }
    }

    final groups = <_NotificationGroup>[];
    if (hoje.isNotEmpty)    groups.add(_NotificationGroup('HOJE',         hoje));
    if (ontem.isNotEmpty)   groups.add(_NotificationGroup('ONTEM',        ontem));
    if (semana.isNotEmpty)  groups.add(_NotificationGroup('ESTA SEMANA',  semana));
    if (antigas.isNotEmpty) groups.add(_NotificationGroup('MAIS ANTIGAS', antigas));
    return groups;
  }
}

class _NotificationGroup {
  final String label;
  final List<NotificationModel> items;
  const _NotificationGroup(this.label, this.items);
}
