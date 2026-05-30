// --- Balcão hub page ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Two tabs:
//   1. "Mercado" — list of startups available to trade with per-row variation
//      since the user's average purchase price. Tapping a row jumps to the
//      per-startup balcão page.
//   2. "Minhas Ordens" — every order this user has, with the option to edit
//      or cancel pending ones.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/balcao/controllers/balcao_controller.dart';
import 'package:mesclainvest/pages/balcao/models/order_model.dart';
import 'package:mesclainvest/pages/balcao/widgets/edit_order_dialog.dart';
import 'package:mesclainvest/pages/dashboard/widgets/deposit_prompt_card.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- CONSTANTS ---

const _kBuyColor  = Color(0xFF16A34A);
const _kSellColor = Color(0xFFDC2626);
// Wallet card stays dark on both themes (deliberate brand accent).
const _kWalletBg     = Color(0xFF111111);
const _kWalletFg     = Color(0xFFFFFFFF);
const _kWalletButtonBg = Color(0xFF2A2A2D);

final _currencyFmt = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
  decimalDigits: 2,
);
final _intFmt = NumberFormat.decimalPattern('pt_BR');

// --- PAGE ---

/// Hub page of the balcão (P2P market).
///
/// Renders the dashboard-style header, a wallet-balance card with a deposit
/// shortcut, two pill tabs ("Mercado" / "Minhas Ordens") and the matching
/// content list. Lives at the `/balcao` route and is part of the bottom
/// navigation bar.
class BalcaoPage extends StatefulWidget {
  const BalcaoPage({super.key});

  @override
  State<BalcaoPage> createState() => _BalcaoPageState();
}

class _BalcaoPageState extends State<BalcaoPage> {
  final BalcaoController _controller = BalcaoController();
  final TextEditingController _searchCtrl = TextEditingController();
  int _activeTab = 0; // 0 = Mercado, 1 = Minhas Ordens
  int _lastNavVersion = 0;

  @override
  void initState() {
    super.initState();
    _lastNavVersion = AppState.instance.navVersion;
    _controller.load();
    AppState.instance.addListener(_onNavChanged);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onNavChanged);
    _controller.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onNavChanged() {
    if (!mounted) return;
    final v = AppState.instance.navVersion;
    if (v != _lastNavVersion) {
      _lastNavVersion = v;
      _controller.load(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to both the page controller AND AppState so the header rebuilds
    // when the profile finishes loading (Firebase Auth restores asynchronously
    // on web, so the profile is often null when the first frame is painted).
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, AppState.instance]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground(context),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balcão de Ativos',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ordens de compra e venda de tokens',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _WalletCard(controller: _controller),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _PillTabs(
                    active: _activeTab,
                    onChange: (i) => setState(() => _activeTab = i),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SearchBar(controller: _searchCtrl, balcao: _controller),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _activeTab == 0
                      ? _MercadoTab(controller: _controller)
                      : _MyOrdersTab(controller: _controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// --- USER HEADER ---



// --- WALLET CARD ---
// Black accent card showing the wallet balance and the deposit shortcut.
// Stays dark on both themes by design.

class _WalletCard extends StatelessWidget {
  final BalcaoController controller;
  const _WalletCard({required this.controller});

  void _openDeposit(BuildContext context) {
    showDepositDialog(
      context: context,
      onDeposit: controller.deposit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = controller.walletBalance;
    final loading = controller.isLoadingWallet;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        color: _kWalletBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VALOR DISPONÍVEL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _kWalletFg.withValues(alpha: 0.55),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    loading ? 'R\$ —' : _currencyFmt.format(balance),
                    key: ValueKey<String>(loading ? '_' : balance.toString()),
                    style: moneyStyle(
                      fontSize: 22,
                      color: _kWalletFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openDeposit(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _kWalletButtonBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Depositar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kWalletFg,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.add, size: 16, color: _kWalletFg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// --- PILL TABS ---
// Two equal-width buttons: the active one is filled (textPrimary), the other
// is just an outline. Used in place of the underline TabBar to match the
// prototype.

class _PillTabs extends StatelessWidget {
  final int active;
  final ValueChanged<int> onChange;
  const _PillTabs({required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _pill(context, label: 'Mercado',       index: 0)),
        const SizedBox(width: 10),
        Expanded(child: _pill(context, label: 'Minhas Ordens', index: 1)),
      ],
    );
  }

  Widget _pill(BuildContext context, {required String label, required int index}) {
    final isActive = active == index;
    return GestureDetector(
      onTap: () => onChange(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.textPrimary(context)
              : AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.textPrimary(context)
                : AppColors.border(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isActive
                ? AppColors.surfaceColor(context)
                : AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }
}


// --- SEARCH BAR ---

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final BalcaoController balcao;
  const _SearchBar({required this.controller, required this.balcao});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    return TextField(
      controller: widget.controller,
      onChanged: (v) {
        widget.balcao.updateSearch(v);
        setState(() {});
      },
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary(context),
      ),
      decoration: InputDecoration(
        hintText: 'Buscar startup ou ticket',
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted(context),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textMuted(context),
          size: 20,
        ),
        suffixIcon: hasText
            ? GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.balcao.updateSearch('');
                  setState(() {});
                },
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textMuted(context),
                ),
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        filled: true,
        fillColor: AppColors.surfaceColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textPrimary(context), width: 1.5),
        ),
      ),
    );
  }
}


// --- MERCADO TAB ---

class _MercadoTab extends StatelessWidget {
  final BalcaoController controller;
  const _MercadoTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingStartups) {
      return Center(child: CircularProgressIndicator(color: AppColors.textPrimary(context)));
    }

    if (controller.startupsError != null) {
      return _ErrorView(
        message: controller.startupsError!,
        onRetry: controller.loadStartups,
      );
    }

    final list = controller.filteredStartups;
    if (list.isEmpty) {
      return _EmptyView(
        icon: Icons.search_off,
        message: controller.searchQuery.isEmpty
            ? 'Nenhuma startup disponível ainda.'
            : 'Nenhuma startup encontrada para "${controller.searchQuery}".',
      );
    }

    return RefreshIndicator(
      color: AppColors.textPrimary(context),
      onRefresh: () async {
        await Future.wait([
          controller.loadStartups(),
          controller.loadWalletAndHoldings(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        children: [
          _MercadoHeaderRow(controller: controller),
          const SizedBox(height: 6),
          for (final s in list)
            _MercadoRow(
              startup:   s,
              variation: controller.variationFor(s.id) ?? s.changePercent,
              onReturn: () => controller.load(),
            ),
        ],
      ),
    );
  }
}

class _MercadoHeaderRow extends StatelessWidget {
  final BalcaoController controller;
  const _MercadoHeaderRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _SortHeader(
              label: 'STARTUP / TICKET',
              column: BalcaoSort.nome,
              controller: controller,
              align: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 3,
            child: _SortHeader(
              label: 'PREÇO',
              column: BalcaoSort.preco,
              controller: controller,
              align: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: _SortHeader(
              label: 'VAR %',
              column: BalcaoSort.variacao,
              controller: controller,
              align: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortHeader extends StatelessWidget {
  final String label;
  final BalcaoSort column;
  final BalcaoController controller;
  final TextAlign align;
  const _SortHeader({
    required this.label,
    required this.column,
    required this.controller,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = controller.sort == column;
    final color    = isActive
        ? AppColors.textPrimary(context)
        : AppColors.textMuted(context);

    final icon = isActive
        ? (controller.sortAsc ? Icons.arrow_upward : Icons.arrow_downward)
        : null;

    final textStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.5,
    );

    Widget content;
    if (align == TextAlign.right) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 2),
          ],
          Text(label, style: textStyle),
        ],
      );
    } else {
      content = Row(
        children: [
          Text(label, style: textStyle),
          if (icon != null) ...[
            const SizedBox(width: 2),
            Icon(icon, size: 10, color: color),
          ],
        ],
      );
    }

    return GestureDetector(
      onTap: () => controller.setSort(column),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      ),
    );
  }
}

class _MercadoRow extends StatelessWidget {
  final StartupModel startup;
  final double? variation;
  final VoidCallback onReturn;
  const _MercadoRow({
    required this.startup,
    required this.variation,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final tokenName = startup.tokenName.isEmpty
        ? startup.name.substring(0, startup.name.length > 4 ? 4 : startup.name.length).toUpperCase()
        : startup.tokenName;

    return GestureDetector(
      onTap: () async {
        await context.push('/startup/${startup.id}/balcao');
        onReturn();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  _Logo(url: startup.logoUrl, name: startup.name, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          startup.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          tokenName,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                _currencyFmt.format(startup.tokenPrice),
                textAlign: TextAlign.right,
                style: moneyStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: _VariationCell(variation: variation),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariationCell extends StatelessWidget {
  final double? variation;
  const _VariationCell({required this.variation});

  @override
  Widget build(BuildContext context) {
    if (variation == null) {
      return Text(
        '—',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted(context),
        ),
      );
    }
    final v = variation!;
    final isUp = v >= 0;
    final color = isUp ? _kBuyColor : _kSellColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          isUp ? Icons.trending_up : Icons.trending_down,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${isUp ? '+' : ''}${v.toStringAsFixed(2)}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}


// --- MINHAS ORDENS TAB ---

class _MyOrdersTab extends StatelessWidget {
  final BalcaoController controller;
  const _MyOrdersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingOrders) {
      return Center(child: CircularProgressIndicator(color: AppColors.textPrimary(context)));
    }

    if (controller.ordersError != null) {
      return _ErrorView(
        message: controller.ordersError!,
        onRetry: controller.loadMyOrders,
      );
    }

    final query = controller.searchQuery;
    final filtered = query.isEmpty
        ? controller.orders
        : controller.orders.where((o) {
            return o.startupName.toLowerCase().contains(query) ||
                o.tokenName.toLowerCase().contains(query);
          }).toList();

    if (filtered.isEmpty) {
      return _EmptyView(
        icon: Icons.receipt_long_outlined,
        message: controller.orders.isEmpty
            ? 'Você ainda não tem ordens no balcão.'
            : 'Nenhuma ordem encontrada para "$query".',
      );
    }

    return RefreshIndicator(
      color: AppColors.textPrimary(context),
      onRefresh: controller.loadMyOrders,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final o = filtered[i];
          return _OrderCard(
            order:        o,
            isCancelling: controller.isCancelling(o.orderId),
            isEditing:    controller.isEditing(o.orderId),
            onCancel:     () => _confirmCancel(context, o),
            onEdit:       () => _openEdit(context, o),
          );
        },
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, OrderModel order) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar ordem?'),
        content: Text(
          'A parte que já foi negociada (${order.filledQuantity} de ${order.quantity}) '
          'permanece. Só a quantidade restante (${order.remaining}) será cancelada.',
        ),
        actions: [
          AppButton(
            label: 'Voltar',
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
            fullWidth: false,
            onPressed: () => Navigator.of(dialogCtx).pop(false),
          ),
          AppButton(
            label: 'Cancelar ordem',
            variant: AppButtonVariant.destructive,
            size: AppButtonSize.small,
            fullWidth: false,
            onPressed: () => Navigator.of(dialogCtx).pop(true),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final err = await controller.cancelOrder(order.orderId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Ordem cancelada.'),
        backgroundColor: err == null ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, OrderModel order) async {
    final result = await showEditOrderDialog(context: context, order: order);
    if (result == null || !context.mounted) return;

    final err = await controller.updateOrder(
      original:      order,
      newQuantity:   result.quantity,
      newUnitPrice:  result.unitPrice,
    );
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Ordem atualizada.'),
        backgroundColor: err == null ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isCancelling;
  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onEdit;

  const _OrderCard({
    required this.order,
    required this.isCancelling,
    required this.isEditing,
    required this.onCancel,
    required this.onEdit,
  });

  static final _dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');

  @override
  Widget build(BuildContext context) {
    final isBuy         = order.isBuy;
    final sideColor     = isBuy ? _kBuyColor : _kSellColor;
    final sideBg        = isBuy ? const Color(0x1416A34A) : const Color(0x14DC2626);
    final tokenName     = order.tokenName.isEmpty ? order.startupName : order.tokenName;
    final total         = order.unitPrice * order.quantity;
    final statusLabel   = _statusLabel(order.status);
    final statusColor   = _statusColor(order.status);
    final showActions   = order.isOpen;
    final hasProgress   = order.filledQuantity > 0 && order.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent bar ─────────────────────────
              Container(width: 4, color: sideColor),

              // ── Card body ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Header: logo + name + type chip + status
                    Container(
                      color: AppColors.surfaceColor(context),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Row(
                        children: [
                          _Logo(url: order.startupLogoUrl ?? '', name: order.startupName, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.startupName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$tokenName · ${_dateFmt.format(order.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sideBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isBuy ? 'COMPRA' : 'VENDA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: sideColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _StatusBadge(label: statusLabel, color: statusColor),
                        ],
                      ),
                    ),

                    // Stats grid: QUANTIDADE | PREÇO/TOKEN | TOTAL
                    Container(
                      color: AppColors.surfaceMuted(context),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCell(
                                label: 'QUANTIDADE',
                                value: '${_intFmt.format(order.quantity)} tokens',
                              ),
                            ),
                            VerticalDivider(width: 1, color: AppColors.border(context)),
                            Expanded(
                              child: _StatCell(
                                label: 'PREÇO/TOKEN',
                                value: _currencyFmt.format(order.unitPrice),
                                isMonetary: true,
                              ),
                            ),
                            VerticalDivider(width: 1, color: AppColors.border(context)),
                            Expanded(
                              child: _StatCell(
                                label: 'TOTAL',
                                value: _currencyFmt.format(total),
                                valueColor: sideColor,
                                isMonetary: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Progress bar for partially filled pending orders
                    if (hasProgress) ...[
                      Container(
                        color: AppColors.surfaceColor(context),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Execução parcial',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted(context),
                                  ),
                                ),
                                Text(
                                  '${_intFmt.format(order.filledQuantity)} / ${_intFmt.format(order.quantity)} tokens'
                                  ' · ${(order.progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: sideColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: order.progress,
                                minHeight: 5,
                                backgroundColor: AppColors.border(context),
                                color: sideColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Action buttons (pending orders only)
                    if (showActions) ...[
                      Divider(height: 1, color: AppColors.border(context)),
                      Container(
                        color: AppColors.surfaceColor(context),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                label:     'EDITAR',
                                color:     AppColors.surfaceMuted(context),
                                fgColor:   AppColors.textPrimary(context),
                                isLoading: isEditing,
                                onTap:     isCancelling ? null : onEdit,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                label:     'CANCELAR',
                                color:     _kSellColor.withValues(alpha: 0.12),
                                fgColor:   _kSellColor,
                                isLoading: isCancelling,
                                onTap:     isEditing ? null : onCancel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'pending'   => 'Aberta',
        'completed' => 'Executada',
        'cancelled' => 'Cancelada',
        'failed'    => 'Falhou',
        _ => status,
      };

  Color _statusColor(String status) => switch (status) {
        'pending'   => _kBuyColor,
        'completed' => Colors.blueGrey,
        'cancelled' => Colors.grey,
        'failed'    => _kSellColor,
        _ => Colors.grey,
      };
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMonetary;
  const _StatCell({required this.label, required this.value, this.valueColor, this.isMonetary = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: isMonetary
                ? moneyStyle(
                    fontSize: 12,
                    color: valueColor ?? AppColors.textPrimary(context),
                  )
                : TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? AppColors.textPrimary(context),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color fgColor;
  final bool isLoading;
  final VoidCallback? onTap;
  const _ActionButton({
    required this.label,
    required this.color,
    required this.fgColor,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null ? color.withValues(alpha: 0.5) : color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                  letterSpacing: 0.6,
                ),
              ),
      ),
    );
  }
}


// --- SHARED UI ---

class _Logo extends StatelessWidget {
  final String url;
  final String name;
  final double size;
  const _Logo({required this.url, required this.name, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final initial = Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceMuted(context),
      ),
      // Image.network with errorBuilder so a broken URL falls back to the
      // initial letter instead of leaving an empty grey circle.
      child: ClipOval(
        child: url.isEmpty
            ? initial
            : Image.network(
                url,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (_, _, _) => initial,
              ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted(context)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.textMuted(context)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Tentar novamente',
              size: AppButtonSize.small,
              fullWidth: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
