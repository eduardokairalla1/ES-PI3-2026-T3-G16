import 'package:flutter/material.dart';


/// Atalhos para ações principais (Depósito, Compra, Venda, Extrato).
class BotoesAcao extends StatelessWidget {
  
  final DashboardController controller;

  // construtor
  const BotoesAcao({super.key, required this.controller});


  /// Abre o pop-up de depósito (Simulação bancária).
  void _mostrarDialogoDeposito(BuildContext context) {
    final TextEditingController valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Depositar Saldo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digite o valor que deseja simular o depósito em sua conta MesclaInvest.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Valor (R$)',
                prefixText: 'R$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final String valorText = valorController.text;
              final double? valor = double.tryParse(valorText.replaceAll(',', '.'));
              
              if (valor != null && valor > 0) {
                try {
                  // Fecha o teclado
                  FocusScope.of(context).unfocus();
                  
                  // Chama o controller para processar o depósito
                  await controller.deposit(valor);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Depósito de R$ ${valor.toStringAsFixed(2)} realizado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao realizar depósito: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirmar Depósito', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // item: depositar (destaque)
          _BotaoAcaoItem(
            icon: Icons.add,
            label: 'Depositar',
            isPrimary: true,
            onTap: () => _mostrarDialogoDeposito(context),
          ),

          // item: comprar
          _BotaoAcaoItem(
            icon: Icons.trending_up,
            label: 'Comprar',
            onTap: () {},
          ),

          // item: vender (saque)
          _BotaoAcaoItem(
            icon: Icons.account_balance_outlined,
            label: 'Vender',
            onTap: () {},
          ),

          // item: extrato
          _BotaoAcaoItem(
            icon: Icons.receipt_long_outlined,
            label: 'Extrato',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}


/// Botão de ação individual.
class _BotaoAcaoItem extends StatelessWidget {

  // atributos
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  // construtor
  const _BotaoAcaoItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
    
          // container arredondado (squircle) do ícone
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isPrimary ? Colors.black : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isPrimary ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
    
          const SizedBox(height: 8),
    
          // rótulo do botão
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              color: isPrimary ? Colors.black : Colors.grey.shade600,
            ),
          ),
    
        ],
      ),
    );
  }
}