import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

class OrderBookPage extends StatelessWidget {
  final String startupId;

  const OrderBookPage({super.key, required this.startupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _OrderBookList(startupId: startupId),
            ),
            _buildBottomPanel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Livro de Ofertas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: AppButton(
        label: 'NOVA ORDEM',
        onPressed: () {
           // We can open a modal here, or navigate to a new screen.
           // For simplicity and reusing the PDF's requirement, we will redirect 
           // the user to the startup page where the InvestPanel will handle the order form.
           context.push('/startup/$startupId');
        },
      ),
    );
  }
}

class _OrderBookList extends StatelessWidget {
  final String startupId;

  const _OrderBookList({required this.startupId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('startup_id', isEqualTo: startupId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar livro de ofertas.'));
        }

        final docs = snapshot.data?.docs ?? [];
        
        final buyOrders = docs.where((d) => d['type'] == 'buy').toList();
        final sellOrders = docs.where((d) => d['type'] == 'sell').toList();

        // Sort: Buy orders descending (highest bid at top), Sell orders descending (lowest ask at bottom)
        buyOrders.sort((a, b) => (b['unit_price'] as num).compareTo(a['unit_price'] as num));
        sellOrders.sort((a, b) => (b['unit_price'] as num).compareTo(a['unit_price'] as num));

        // In a real order book, we aggregate quantities by price. 
        // For simplicity we show individual orders.

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PREÇO (R\$)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                    Text('QUANT.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                    Text('TOTAL (R\$)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              
              // Sell Orders (Red)
              if (sellOrders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhuma oferta de venda', textAlign: TextAlign.center, style: TextStyle(color: Colors.black38)),
                )
              else
                ...sellOrders.map((d) => _OrderRow(data: d.data() as Map<String, dynamic>, isBuy: false)),
              
              const Divider(height: 24, thickness: 1.5),

              // Buy Orders (Green)
              if (buyOrders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhuma oferta de compra', textAlign: TextAlign.center, style: TextStyle(color: Colors.black38)),
                )
              else
                ...buyOrders.map((d) => _OrderRow(data: d.data() as Map<String, dynamic>, isBuy: true)),
            ],
          ),
        );
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isBuy;

  const _OrderRow({required this.data, required this.isBuy});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    final price = (data['unit_price'] as num).toDouble();
    final quantity = (data['quantity'] as num).toInt();
    final total = price * quantity;
    final color = isBuy ? Colors.green.shade600 : Colors.red.shade600;
    final bgColor = isBuy ? Colors.green.shade50 : Colors.red.shade50;
    final isMine = data['uid'] == FirebaseAuth.instance.currentUser?.uid;

    return Container(
      color: bgColor.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              currencyFmt.format(price),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormat.decimalPattern('pt_BR').format(quantity),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                if (isMine) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _cancelOrder(context, data['id']),
                    child: Icon(Icons.cancel, size: 16, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              currencyFmt.format(total),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Ordem?'),
        content: const Text('Tem certeza que deseja cancelar esta ordem? Os ativos serão estornados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('NÃO', style: TextStyle(color: Colors.black))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SIM', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await FirebaseFunctions.instance.httpsCallable('onCancelOrder').call({'orderId': orderId});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ordem cancelada com sucesso.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao cancelar ordem.')));
        }
      }
    }
  }
}
