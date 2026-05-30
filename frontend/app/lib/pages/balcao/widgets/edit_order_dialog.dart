// --- Edit order dialog ---
// Pedro Henrique Medeiros dos Reis - 24801656
//
// Modal that lets the user edit a pending P2P order. Internally the edit is
// implemented as "cancel old + create new" — this file owns only the form
// UI; the orchestration lives in `BalcaoController.updateOrder`.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/balcao/models/order_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- TYPES ---

/// Result returned by [showEditOrderDialog] when the user confirms.
///
/// [quantity] is the new total quantity (replaces the original order entirely
/// — it is NOT additive). [unitPrice] is the new per-token price.
class EditOrderResult {
  final int quantity;
  final double unitPrice;

  const EditOrderResult({required this.quantity, required this.unitPrice});
}

// --- ENTRY POINT ---

/// Opens the edit-order dialog pre-filled with [order]'s current quantity and
/// price. Returns the new values on confirm, or `null` if the user dismissed
/// the dialog without saving.
///
/// The dialog itself does NOT perform the edit — the caller is expected to
/// pass the result to `BalcaoController.updateOrder(...)`. Keeping the
/// modal pure means it can be unit-tested without any Firebase wiring.
Future<EditOrderResult?> showEditOrderDialog({
  required BuildContext context,
  required OrderModel order,
}) {
  return showDialog<EditOrderResult>(
    context: context,
    builder: (dialogCtx) => _EditOrderDialog(order: order),
  );
}


// --- WIDGET ---

class _EditOrderDialog extends StatefulWidget {
  final OrderModel order;
  const _EditOrderDialog({required this.order});

  @override
  State<_EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<_EditOrderDialog> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  final _currencyFmt = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  String? _error;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
      text: widget.order.unitPrice.toStringAsFixed(2).replaceAll('.', ','),
    );
    _qtyCtrl = TextEditingController(text: widget.order.quantity.toString());
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  // Convert BRL-formatted "1.234,56" into 1234.56.
  double _parsePrice(String raw) {
    final cleaned = raw.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  int _parseQty(String raw) {
    final cleaned = raw.replaceAll('.', '').replaceAll(',', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  void _submit() {
    final price = _parsePrice(_priceCtrl.text);
    final qty   = _parseQty(_qtyCtrl.text);

    if (price <= 0) {
      setState(() => _error = 'Informe um preço válido.');
      return;
    }
    if (qty <= 0) {
      setState(() => _error = 'Informe uma quantidade válida.');
      return;
    }
    if (qty < widget.order.filledQuantity) {
      setState(() => _error =
          'A nova quantidade não pode ser menor do que a já preenchida (${widget.order.filledQuantity}).');
      return;
    }

    Navigator.of(context).pop(
      EditOrderResult(quantity: qty, unitPrice: price),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.order.isBuy;
    final typeLabel = isBuy ? 'compra' : 'venda';
    final price = _parsePrice(_priceCtrl.text);
    final qty   = _parseQty(_qtyCtrl.text);
    final total = price * qty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Editar ordem de $typeLabel',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary(context),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A ordem antiga será cancelada e uma nova será criada com os '
            'valores abaixo.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label:       'Preço por token (R\$)',
            controller:  _priceCtrl,
            hint:        '0,00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,]'))],
            onChanged:   (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label:       'Quantidade (tokens)',
            controller:  _qtyCtrl,
            hint:        '0',
            keyboardType: TextInputType.number,
            onChanged:   (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 14),
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
                  style: moneyStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ],
        ],
      ),
      actions: [
        AppButton(
          label:     'Voltar',
          variant:   AppButtonVariant.text,
          size:      AppButtonSize.small,
          fullWidth: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label:     'Salvar',
          size:      AppButtonSize.small,
          fullWidth: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.inputFormatters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted(context)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.surfaceColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.textPrimary(context), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
