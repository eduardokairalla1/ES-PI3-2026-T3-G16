/*
 * Modelo de transação do Dashboard.
 * Normaliza o histórico financeiro retornado pelo backend para a UI.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */
library;

/*
 * TYPES
 */

/// Entidade que representa uma transação unificada no extrato da conta do investidor.
/// Normaliza depósitos de carteira e negociações de ativos (compra/venda).
class TransactionModel {
  /// Identificador único da transação (Doc ID do Firestore).
  final String id;
  
  /// Valor financeiro total envolvido na transação.
  final double amount;
  
  /// Descrição amigável legível da transação (ex: "Depósito em conta", "Compra de tokens — StartupX").
  final String description;
  
  /// Data e hora do registro/efetivação da movimentação.
  final DateTime createdAt;
  
  /// Tipo de transação (ex: 'deposit' para depósitos, 'buy' para compras de token, 'sell' para vendas).
  final String type;
  
  /// Status atual do processamento da transação (ex: 'completed', 'pending').
  final String status;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.type,
    required this.status,
  });

  /// Cria uma instância de [TransactionModel] decodificando um mapa de atributos vindo da Cloud Function.
  /// Implementa tratamento robusto para conversão de datas vindas do Firebase (Timestamps, milissegundos ou strings ISO).
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    // Parse de data tratando diferentes formatos de serialização do Firebase:
    // - Mapa com '_seconds' (comum em chamadas HTTP/SDK Web)
    // - Inteiro representando timestamp em milissegundos
    // - String em formato ISO 8601
    // - Fallback padrão para DateTime.now() em caso de ausência ou falha no parse
    DateTime date;
    try {
      final raw = map['created_at'];
      if (raw is Map &&
          (raw.containsKey('_seconds') || raw.containsKey('seconds'))) {
        final seconds = (raw['_seconds'] ?? raw['seconds']) as int;
        date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else if (raw is int) {
        date = DateTime.fromMillisecondsSinceEpoch(raw);
      } else if (raw is String) {
        date = DateTime.parse(raw);
      } else {
        date = DateTime.now();
      }
    } catch (_) {
      date = DateTime.now();
    }

    return TransactionModel(
      id: map['id'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String? ?? 'Transação',
      createdAt: date,
      type: map['type'] as String? ?? 'other',
      status: map['status'] as String? ?? 'completed',
    );
  }
}
