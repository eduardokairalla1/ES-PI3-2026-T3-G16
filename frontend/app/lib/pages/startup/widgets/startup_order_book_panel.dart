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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/balcao/models/order_book_model.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_order_book_controller.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

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

  // tap on an order card → prefill the form with its price + remaining qty,
  // and flip the side (taking the offer is the opposite action of the seller)
  void _onOrderTap(OpenOrderEntry entry, {required bool isSellOffer}) {
    _priceCtrl.text = entry.price.toStringAsFixed(2).replaceAll('.', ',');
    _qtyCtrl.text   = entry.remaining.toString();
    // tapping a sell offer means "I want to buy"; tapping a buy offer means
    // "I want to sell" — flip the side automatically
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
        SnackBar(content: Text(msg)),
      );
      _qtyCtrl.clear();
    }
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return RefreshIndicator(
          color: AppColors.textPrimary(context),
          onRefresh: _controller.refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _header(),
              const SizedBox(height: 16),
              _form(),
              const SizedBox(height: 24),
              _sellSection(),
              const SizedBox(height: 24),
              _buySection(),
            ],
          ),
        );
      },
    );
  }

  // --- HEADER (last trade + refresh indicator) ---

  Widget _header() {
    final last = _controller.book.lastTradePrice;
    final tokenName = widget.startup.tokenName.isEmpty
        ? widget.startup.name
        : widget.startup.tokenName;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$tokenName/BRL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  last != null
                      ? 'Último negócio: ${_currencyFmt.format(last)}'
                      : 'Sem negócios fechados ainda',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFmt.format(widget.startup.tokenPrice),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                'preço de mercado',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          if (_controller.isRefreshing) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- FORM ---

  Widget _form() {
    final isBuy = _controller.selectedType == 'buy';
    final tokenName = widget.startup.tokenName.isEmpty
        ? widget.startup.name
        : widget.startup.tokenName;

    final price = _parsePrice(_priceCtrl.text);
    final qty   = _parseQty(_qtyCtrl.text);
    final total = price * qty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // buy/sell toggle
          Row(
            children: [
              Expanded(
                child: _typeButton(
                  label: 'Compra',
                  color: _kBuyColor,
                  selected: isBuy,
                  onTap: () => _controller.selectType('buy'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _typeButton(
                  label: 'Venda',
                  color: _kSellColor,
                  selected: !isBuy,
                  onTap: () => _controller.selectType('sell'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _labeledField(
            label: 'Preço por token (R\$)',
            controller: _priceCtrl,
            hint: '0,00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _labeledField(
            label: 'Quantidade (tokens)',
            controller: _qtyCtrl,
            hint: '0',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBuy ? 'Total a pagar:' : 'Total a receber:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Text(
                  _currencyFmt.format(total),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          if (_controller.submitError != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.submitError!,
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ],
          const SizedBox(height: 14),
          _submitButton(isBuy, tokenName),
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
          onChanged: (_) => setState(() {}),
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
    final label = isBuy ? 'Comprar $tokenName' : 'Vender $tokenName';

    return GestureDetector(
      onTap: _controller.isSubmitting ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _controller.isSubmitting ? color.withValues(alpha: 0.5) : color,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  // --- SELL / BUY SECTIONS ---

  Widget _sellSection() {
    return _section(
      title:       'Ofertas de venda',
      count:       _controller.book.sellOrders.length,
      color:       _kSellColor,
      bg:          _kSellBg,
      isSellSide:  true,
      orders:      _controller.book.sellOrders,
      emptyLabel:  'Ninguém está vendendo agora.',
    );
  }

  Widget _buySection() {
    return _section(
      title:       'Ofertas de compra',
      count:       _controller.book.buyOrders.length,
      color:       _kBuyColor,
      bg:          _kBuyBg,
      isSellSide:  false,
      orders:      _controller.book.buyOrders,
      emptyLabel:  'Ninguém está comprando agora.',
    );
  }

  Widget _section({
    required String title,
    required int count,
    required Color color,
    required Color bg,
    required bool isSellSide,
    required List<OpenOrderEntry> orders,
    required String emptyLabel,
  }) {
    if (_controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(color: AppColors.textPrimary(context))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        if (orders.isEmpty)
          _emptyState(emptyLabel)
        else
          ...orders.map((o) => _OrderCard(
                entry:        o,
                color:        color,
                bg:           bg,
                marketPrice:  _controller.book.currentMarketPrice == 0
                    ? widget.startup.tokenPrice
                    : _controller.book.currentMarketPrice,
                isSellSide:   isSellSide,
                currencyFmt:  _currencyFmt,
                intFmt:       _intFmt,
                onTap:        () => _onOrderTap(o, isSellOffer: isSellSide),
              )),
      ],
    );
  }

  Widget _emptyState(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary(context),
          ),
        ),
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
  final VoidCallback onTap;

  const _OrderCard({
    required this.entry,
    required this.color,
    required this.bg,
    required this.marketPrice,
    required this.isSellSide,
    required this.currencyFmt,
    required this.intFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // variance vs market — positive means the offer is above market price
    final variance = marketPrice == 0
        ? 0.0
        : ((entry.price - marketPrice) / marketPrice) * 100;
    final varianceLabel = '${variance >= 0 ? '+' : ''}${variance.toStringAsFixed(2)}%';
    // for sells, a NEGATIVE variance is "cheaper than market" → good for buyer
    // for buys,  a POSITIVE variance is "more than market"   → good for seller
    final isFavorable = isSellSide ? variance < 0 : variance > 0;

    final actionLabel = isSellSide ? 'COMPRAR' : 'ACEITAR';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isFavorable ? _kBuyColor : AppColors.textSecondary(context),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              // action hint
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
