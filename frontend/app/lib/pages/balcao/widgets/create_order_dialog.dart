import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/startup/services/startup_service.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

class CreateOrderDialog extends StatefulWidget {
  final String startupId;

  const CreateOrderDialog({super.key, required this.startupId});

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  final _startupService = StartupService();
  
  String _type = 'buy';
  int _quantity = 100;
  double _price = 0.50;
  bool _isLoading = false;
  String? _error;

  void _submit() async {
    if (_quantity <= 0 || _price <= 0) {
      setState(() => _error = 'Quantidade e preço devem ser maiores que zero.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _startupService.createOrder(
        widget.startupId,
        _quantity,
        _price,
        _type,
      );
      if (mounted) {
        Navigator.pop(context, true); // Retorna true indicando sucesso
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao criar ordem. Verifique seu saldo de carteira ou tokens.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova Ordem',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Insira os detalhes da oferta',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Tipo de Ordem
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption('Compra', 'buy', Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeOption('Venda', 'sell', Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preço
            TextFormField(
              initialValue: _price.toStringAsFixed(2),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Preço Unitário (R\$)',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => _price = double.tryParse(val.replaceAll(',', '.')) ?? 0,
            ),
            const SizedBox(height: 16),

            // Quantidade
            TextFormField(
              initialValue: _quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade de Tokens',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => _quantity = int.tryParse(val) ?? 0,
            ),
            
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    label: 'Confirmar',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? () {} : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, String value, Color color) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
