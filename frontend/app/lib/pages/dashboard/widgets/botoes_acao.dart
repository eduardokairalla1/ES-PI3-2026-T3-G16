/**
 * Widgets para os botões de ação do Dashboard (Depositar, Comprar, Vender, Extrato).
 *
 * Alex Gabriel Soares Sousa - 24802449
 */


/**
 * IMPORTS
 */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';


/**
 * CODE
 */

/// Widget principal que agrupa os botões de atalho da dashboard.
class BotoesAcao extends StatelessWidget {
  
  // Atributos
  final DashboardController controller;

  // Construtor
  const BotoesAcao({super.key, required this.controller});


  /**
   * MÉTODOS PRIVADOS
   */

  /// Abre o pop-up de depósito (Simulação bancária).
  /// Possui fluxo de dois passos: Entrada de Valor e Confirmação.
  void _mostrarDialogoDeposito(BuildContext context) {
    final TextEditingController valorController = TextEditingController();
    bool isProcessando = false;
    bool mostrarConfirmacao = false;
    double? valorFinal;

    showDialog(
      context: context,
      barrierDismissible: !isProcessando,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              mostrarConfirmacao ? 'Confirmar Depósito' : 'Depositar Saldo',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: mostrarConfirmacao
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Você confirma o depósito de:'),
                        const SizedBox(height: 12),
                        Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valorFinal),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Este valor será adicionado instantaneamente à sua carteira simulada.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    )
                  : Column(
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
                            labelText: 'Valor (R\$)',
                            prefixText: 'R\$ ',
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
            ),
            actions: [
              TextButton(
                onPressed: isProcessando ? null : () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isProcessando
                    ? null
                    : () async {
                        if (!mostrarConfirmacao) {
                          // Passo 1: Validação e preparação da confirmação
                          final String rawValue = valorController.text.replaceAll('.', '').replaceAll(',', '.');
                          final double? parsedValue = double.tryParse(rawValue);

                          if (parsedValue != null && parsedValue > 0) {
                            if (parsedValue > 100000) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('O valor máximo para depósito é R\$ 100.000,00.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            setState(() {
                              valorFinal = parsedValue;
                              mostrarConfirmacao = true;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Por favor, insira um valor válido.')),
                            );
                          }
                        } else {
                          // Passo 2: Execução do depósito via Controller
                          setState(() => isProcessando = true);
                          try {
                            await controller.deposit(valorFinal!);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Depósito de R\$ ${valorFinal!.toStringAsFixed(2)} realizado com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => isProcessando = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isProcessando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        mostrarConfirmacao ? 'Confirmar' : 'Continuar',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }


  /// Abre o pop-up de extrato das movimentações recentes do usuário.
  void _mostrarDialogoExtrato(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, color: Colors.black),
            const SizedBox(width: 12),
            const Text(
              'Extrato Recente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder<List<TransactionModel>>(
            future: controller.getTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma movimentação encontrada.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              }

              final transactions = snapshot.data!;

              return ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  final isPositive = t.type == 'deposit' || t.type == 'sell';
                  final color = isPositive ? Colors.green : Colors.red;
                  final prefix = isPositive ? '+' : '-';
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPositive ? Icons.add : Icons.remove,
                        color: color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      t.description,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      '$prefix ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(t.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.black)),
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
          // Botão: Depositar (Destaque)
          _BotaoAcaoItem(
            icon: Icons.add,
            label: 'Depositar',
            isPrimary: true,
            onTap: () => _mostrarDialogoDeposito(context),
          ),

          // Botão: Comprar
          _BotaoAcaoItem(
            icon: Icons.trending_up,
            label: 'Comprar',
            onTap: () {},
          ),

          // Botão: Vender
          _BotaoAcaoItem(
            icon: Icons.account_balance_outlined,
            label: 'Vender',
            onTap: () {},
          ),

          // Botão: Extrato
          _BotaoAcaoItem(
            icon: Icons.receipt_long_outlined,
            label: 'Extrato',
            onTap: () => _mostrarDialogoExtrato(context),
          ),
        ],
      ),
    );
  }
}



/// Widget interno para representar cada item de ação individual.
class _BotaoAcaoItem extends StatelessWidget {

  // Atributos
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  // Construtor
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
    
          // Círculo/Quadrado arredondado do ícone
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
    
          // Rótulo de texto abaixo do ícone
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