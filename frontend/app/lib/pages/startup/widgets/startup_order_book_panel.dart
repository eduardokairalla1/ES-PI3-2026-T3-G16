// --- Startup order book panel ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Used inside StartupBalcaoPage. Renders:
//   1. Compact header with the token pair + last trade
//   2. Order form (buy/sell toggle, price, quantity, total, submit)
//   3. Two sections of individual order cards:
//      - Sell offers (red)
//      - Buy offers (green)
//      Each card shows price, remaining quantity and the % variance vs the
//      current market price. Tapping a card prefills the form.

// --- IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/balcao/models/order_book_model.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_order_book_controller.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';

// --- CONSTANTS ---

const _kBuyColor  = Color(0xFF16A34A);  // green-600
const _kSellColor = Color(0xFFDC2626);  // red-600
const _kBuyBg     = Color(0x1416A34A);  // green tint
const _kSellBg    = Color(0x14DC2626);  // red tint

// --- WIDGET ---

/// Full balcão panel for a single startup.
///
/// Composes the three sections of the per-startup order book screen:
/// 1. A compact header with the token pair and last completed trade.
/// 2. The buy/sell form (side toggle, price, quantity, total, submit).
/// 3. Two scrollable lists of individual offer cards (sells in red,
///    buys in green) with a `±%` variance pill against the current market
///    price. Tapping a card prefills the form with that offer's price and
///    remaining quantity, flipping the side automatically.
///
/// The panel owns its own [StartupOrderBookController] (5s polling).
class StartupOrderBookPanel extends StatefulWidget {
  /// Startup whose order book is rendered.
  final StartupModel startup;

  /// Builds the panel for [startup].
  const StartupOrderBookPanel({super.key, required this.startup});

  @override
  State<StartupOrderBookPanel> createState() => _StartupOrderBookPanelState();
}

class _StartupOrderBookPanelState extends State<StartupOrderBookPanel> {
  late final StartupOrderBookController _controller;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  final _currencyFmt = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  final _intFmt = NumberFormat.decimalPattern('pt_BR');

  /// Remaining quantity of the currently selected offer (after tapping a card).
  /// Shown as a hint below the quantity field so the user knows the maximum.
  int? _selectedOfferRemaining;

  /// The price text that was set by tapping an offer card. Used to detect
  /// when the user manually edits the price and the offer hint is stale.
  String? _offerPriceText;

  /// Which side of the order book is visible: 'sell' or 'buy'.
  String _selectedBookSide = 'sell';

  @override
  void initState() {
    super.initState();
    _controller = StartupOrderBookController(startupId: widget.startup.id);
    _priceCtrl = TextEditingController(
      text: widget.startup.tokenPrice.toStringAsFixed(2).replaceAll('.', ','),
    );
    _qtyCtrl = TextEditingController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  // --- PARSERS ---

  double _parsePrice(String raw) {
    final cleaned = raw.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  int _parseQty(String raw) {
    final cleaned = raw.replaceAll('.', '').replaceAll(',', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  // tap on an order card → prefill the form with its price only,
  // and flip the side (taking the offer is the opposite action of the seller).
  // The quantity is NOT prefilled — the user chooses how many tokens they want.
  // Own orders are ignored (self-trade prevention).
  void _onOrderTap(OpenOrderEntry entry, {required bool isSellOffer}) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (entry.uid == currentUid) return;

    final priceText = entry.price.toStringAsFixed(2).replaceAll('.', ',');
    _priceCtrl.text     = priceText;
    _offerPriceText     = priceText;
    _qtyCtrl.clear();
    _selectedOfferRemaining = entry.remaining;
    _controller.selectType(isSellOffer ? 'buy' : 'sell');
    setState(() {});
  }

  Future<void> _submit() async {
    final price = _parsePrice(_priceCtrl.text);
    final qty   = _parseQty(_qtyCtrl.text);

    final ok = await _controller.submitOrder(quantity: qty, unitPrice: price);
    if (!mounted) return;

    if (ok) {
      final msg = _controller.lastResultMessage ?? 'Ordem criada.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green.shade700,
        ),
      );
      _qtyCtrl.clear();
      _selectedOfferRemaining = null;
      _offerPriceText         = null;
    }
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _compactHeader(),
            Divider(height: 1, color: AppColors.border(context)),
            _form(),
            Divider(height: 1, color: AppColors.border(context)),
            Expanded(child: _orderBookSection()),
          ],
        );
      },
    );
  }

  // --- COMPACT HEADER ---

  Widget _compactHeader() {
    final last = _controller.book.lastTradePrice;
    final tokenName = widget.startup.tokenName.isEmpty
        ? widget.startup.name
        : widget.startup.tokenName;

    return Container(
      color: AppColors.surfaceColor(context),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: pair name + last trade
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$tokenName/BRL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted(context),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Text(
                        last != null
                            ? 'Último: ${_currencyFmt.format(last)}'
                            : 'Sem negócios ainda',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                    if (_controller.isRefreshing) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Right: market price (prominent)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFmt.format(widget.startup.tokenPrice),
                style: moneyStyle(
                  fontSize: 28,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () => _showPriceInfo(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'preço de mercado',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.help_outline,
                      size: 13,
                      color: AppColors.textMuted(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPriceInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: AppColors.textPrimary(ctx)),
            const SizedBox(width: 8),
            Text(
              'Preço de mercado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(ctx),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoItem(
              ctx,
              icon: Icons.price_change_outlined,
              title: 'O que é',
              body: 'É o valor oficial do token definido pela plataforma Mescla Invest, '
                  'refletindo a avaliação atual da startup.',
            ),
            const SizedBox(height: 14),
            _infoItem(
              ctx,
              icon: Icons.percent,
              title: 'O que significa o ±%',
              body: 'Cada oferta no livro de ordens exibe quanto ela está acima ou abaixo '
                  'do último negócio fechado no balcão P2P — não do preço oficial. '
                  'Isso indica se a oferta está cara ou barata em relação à última transação real.',
            ),
            const SizedBox(height: 14),
            _infoItem(
              ctx,
              icon: Icons.handshake_outlined,
              title: 'Último negócio',
              body: 'É o preço da última transação efetivamente executada entre compradores '
                  'e vendedores no balcão. É a referência mais real do mercado P2P.',
            ),
            const SizedBox(height: 4),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Entendi',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(ctx),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- FORM ---

  Widget _form() {
    final isBuy     = _controller.selectedType == 'buy';
    final sideColor = isBuy ? _kBuyColor : _kSellColor;
    final tokenName = widget.startup.tokenName.isEmpty
        ? widget.startup.name
        : widget.startup.tokenName;
    final price = _parsePrice(_priceCtrl.text);
    final qty   = _parseQty(_qtyCtrl.text);
    final total = price * qty;

    return Container(
      color: AppColors.pageBackground(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // buy/sell toggle
          Row(
            children: [
              Expanded(
                child: _typeButton(
                  label: 'Comprar',
                  color: _kBuyColor,
                  selected: isBuy,
                  onTap: () => _controller.selectType('buy'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _typeButton(
                  label: 'Vender',
                  color: _kSellColor,
                  selected: !isBuy,
                  onTap: () => _controller.selectType('sell'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Owned tokens info
          if (_controller.ownedTokens > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 13, color: AppColors.textMuted(context)),
                  const SizedBox(width: 5),
                  Text(
                    'Você possui ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  Text(
                    _intFmt.format(_controller.ownedTokens),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    ' tokens de $tokenName',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

          // Price + Qty fields side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  label: 'Preço por token (R\$)',
                  controller: _priceCtrl,
                  hint: '0,00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,]'))],
                  onChanged: (val) {
                    if (_selectedOfferRemaining != null && val != _offerPriceText) {
                      _selectedOfferRemaining = null;
                      _offerPriceText = null;
                    }
                    _controller.submitError = null;
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labeledField(
                      label: 'Quantidade (tokens)',
                      controller: _qtyCtrl,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) {
                        _controller.submitError = null;
                        setState(() {});
                      },
                    ),
                    if (_selectedOfferRemaining != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 2),
                        child: Text(
                          'Disponível ${_intFmt.format(_selectedOfferRemaining!)} tokens',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: sideColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Total inline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBuy ? 'Total a pagar' : 'Total a receber',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
              Text(
                _currencyFmt.format(total),
                style: moneyStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),

          if (_controller.submitError != null) ...[
            const SizedBox(height: 6),
            Text(
              _controller.submitError!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
          const SizedBox(height: 12),
          _submitButton(isBuy, tokenName),
          if (!isBuy && _controller.ownedTokens == 0) ...[
            const SizedBox(height: 8),
            Text(
              'Você não possui tokens desta startup para vender.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _typeButton({
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.border(context),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged ?? (_) => setState(() {}),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted(context)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
        ),
      ],
    );
  }

  Widget _submitButton(bool isBuy, String tokenName) {
    final color = isBuy ? _kBuyColor : _kSellColor;
    final label = isBuy ? 'Comprar tokens de $tokenName' : 'Vender tokens de $tokenName';
    final cannotSell = !isBuy && _controller.ownedTokens == 0;
    final disabled   = _controller.isSubmitting || cannotSell;

    return GestureDetector(
      onTap: disabled ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled ? color.withValues(alpha: 0.4) : color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _controller.isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: cannotSell ? 0.6 : 1.0),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  // --- ORDER BOOK (tabbed, scrollable) ---

  Widget _orderBookSection() {
    final sellCount = _controller.book.sellOrders.length;
    final buyCount  = _controller.book.buyOrders.length;
    final isSell    = _selectedBookSide == 'sell';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Fixed header row: title + compact tabs ──────────
        Container(
          color: AppColors.surfaceColor(context),
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            children: [
              Text(
                'Livro de Ordens',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const Spacer(),
              _bookTab(
                label:    'Venda',
                count:    sellCount,
                color:    _kSellColor,
                bg:       _kSellBg,
                selected: isSell,
                onTap:    () => setState(() => _selectedBookSide = 'sell'),
              ),
              const SizedBox(width: 6),
              _bookTab(
                label:    'Compra',
                count:    buyCount,
                color:    _kBuyColor,
                bg:       _kBuyBg,
                selected: !isSell,
                onTap:    () => setState(() => _selectedBookSide = 'buy'),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.border(context)),

        // ── Scrollable list ──────────────────────────────────
        Expanded(
          child: _section(
            color:      isSell ? _kSellColor : _kBuyColor,
            bg:         isSell ? _kSellBg    : _kBuyBg,
            isSellSide: isSell,
            orders:     isSell
                ? _controller.book.sellOrders
                : _controller.book.buyOrders,
            emptyLabel: isSell
                ? 'Ninguém está vendendo agora.'
                : 'Ninguém está comprando agora.',
          ),
        ),
      ],
    );
  }

  Widget _bookTab({
    required String label,
    required int count,
    required Color color,
    required Color bg,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:        selected ? bg : AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(
            color: selected ? color : AppColors.border(context),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: selected ? color : AppColors.textMuted(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w700,
                color: selected ? color : AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color:        selected ? color.withValues(alpha: 0.15) : AppColors.surfaceMuted(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize:   10,
                  fontWeight: FontWeight.w800,
                  color: selected ? color : AppColors.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required Color color,
    required Color bg,
    required bool isSellSide,
    required List<OpenOrderEntry> orders,
    required String emptyLabel,
  }) {
    if (_controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary(context)),
      );
    }

    if (orders.isEmpty) return _emptyState(emptyLabel);

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return RefreshIndicator(
      color: AppColors.textPrimary(context),
      onRefresh: _controller.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        itemCount: orders.length,
        itemBuilder: (context, i) {
          final o = orders[i];
          return _OrderCard(
            entry:          o,
            color:          color,
            bg:             bg,
            marketPrice:    _controller.book.lastTradePrice
                ?? widget.startup.tokenPrice,
            isSellSide:     isSellSide,
            currencyFmt:    _currencyFmt,
            intFmt:         _intFmt,
            currentUserUid: currentUid,
            onTap:          () => _onOrderTap(o, isSellOffer: isSellSide),
          );
        },
      ),
    );
  }

  Widget _emptyState(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}


// --- ORDER CARD ---
// One card per individual open order. Tapping prefills the form.

class _OrderCard extends StatelessWidget {
  final OpenOrderEntry entry;
  final Color color;
  final Color bg;
  final double marketPrice;
  final bool isSellSide;
  final NumberFormat currencyFmt;
  final NumberFormat intFmt;
  final String currentUserUid;
  final VoidCallback onTap;

  const _OrderCard({
    required this.entry,
    required this.color,
    required this.bg,
    required this.marketPrice,
    required this.isSellSide,
    required this.currencyFmt,
    required this.intFmt,
    required this.currentUserUid,
    required this.onTap,
  });

  static String _fmtVariance(double v) {
    final sign = v >= 0 ? '+' : '';
    final abs  = v.abs();
    if (abs >= 9999) return '$sign${(v / 1000).round()}k%';
    if (abs >= 100)  return '$sign${v.toStringAsFixed(0)}%';
    return '$sign${v.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    final isOwnOrder = entry.uid == currentUserUid && currentUserUid.isNotEmpty;

    // variance vs market — positive means the offer is above market price
    final variance = marketPrice == 0
        ? 0.0
        : ((entry.price - marketPrice) / marketPrice) * 100;
    final varianceLabel = _fmtVariance(variance);
    // for sells, a NEGATIVE variance is "cheaper than market" → good for buyer
    // for buys,  a POSITIVE variance is "more than market"   → good for seller
    final isFavorable = isSellSide ? variance < 0 : variance > 0;

    final actionLabel = isSellSide ? 'COMPRAR' : 'ACEITAR';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: isOwnOrder ? null : onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: isOwnOrder
                ? color.withValues(alpha: 0.06)
                : AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOwnOrder ? color.withValues(alpha: 0.4) : AppColors.border(context),
            ),
          ),
          child: Row(
            children: [
              // price column
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFmt.format(entry.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: moneyStyle(
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'por token',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              // quantity column
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intFmt.format(entry.remaining),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'tokens',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              // variance pill
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFavorable
                      ? _kBuyBg
                      : AppColors.surfaceMuted(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  varianceLabel,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isFavorable ? _kBuyColor : AppColors.textSecondary(context),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              // action chip — own orders show "SUA ORDEM"; others show buy/sell
              if (isOwnOrder)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'SUA ORDEM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
