import 'package:flutter_test/flutter_test.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';

void main() {
  group('DashboardData', () {
    test('normaliza o payload consolidado do backend', () {
      final data = DashboardData.fromMap({
        'favoriteIds': ['startup-1', 42],
        'investimentos': [
          {
            'currentPrice': 2.5,
            'startupId': 'startup-1',
            'startupLogoUrl': '',
            'startupName': 'Mescla Labs',
            'tokenQuantity': 10,
            'variation': 5.25,
          },
        ],
        'nomeUsuario': 'Ana Investidora',
        'patrimonioTotal': 1500,
        'rendimentoDiarioPorcentagem': 0.82,
        'rendimentoDiarioValor': 12.3,
        'rentabilidadeMediaMercado': 4.5,
        'saldoDisponivel': 500,
        'totalInvestidoresMercado': 100,
        'totalStartupsMercado': 8,
      });

      expect(data.nomeUsuario, 'Ana Investidora');
      expect(data.patrimonioTotal, 2000);
      expect(data.saldoDisponivel, 500);
      expect(data.favoriteIds, ['startup-1', '42']);
      expect(data.investimentos.single.startupName, 'Mescla Labs');
      expect(data.investimentos.single.tokenQuantity, 10);
    });
  });

  group('TransactionModel', () {
    test('interpreta timestamps serializados pelo Firebase callable', () {
      final transaction = TransactionModel.fromMap({
        'amount': 250,
        'created_at': {'_seconds': 1700000000},
        'description': 'Depósito em conta',
        'id': 'tx-1',
        'status': 'completed',
        'type': 'deposit',
      });

      expect(transaction.id, 'tx-1');
      expect(transaction.amount, 250);
      expect(
        transaction.createdAt,
        DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000),
      );
      expect(transaction.type, 'deposit');
    });
  });
}
