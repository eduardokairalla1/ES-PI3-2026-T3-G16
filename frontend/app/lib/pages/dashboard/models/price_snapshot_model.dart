/*
 * Modelo de snapshot de preço de token.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/// Representa a cotação/valor do token de uma startup em um momento específico do tempo.
class PriceSnapshotModel {
  /// Preço unitário do token registrado no snapshot.
  final double   price;
  
  /// Data e hora do registro da cotação.
  final DateTime recordedAt;

  const PriceSnapshotModel({required this.price, required this.recordedAt});

  /// Instancia o snapshot de preço a partir de chaves/valores vindos do Firestore.
  factory PriceSnapshotModel.fromMap(Map<String, dynamic> map) {
    return PriceSnapshotModel(
      price:      (map['price'] as num).toDouble(),
      recordedAt: _parseTimestamp(map['recordedAt']) ?? DateTime.now(),
    );
  }

  /// Método utilitário privado para decodificar timestamps do Firebase (segundos/milissegundos) para [DateTime].
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final seconds = (value['_seconds'] as num?)?.toInt() ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
    return null;
  }
}


/// Representa o histórico consolidado de preços e informações de custódia do investidor para um token de startup.
class TokenHistoryModel {
  /// Cotação unitária atual do token de startup no mercado.
  final double                   currentPrice;
  
  /// Preço médio pago pelo investidor (nulo se o investidor não tiver posição ativa).
  final double?                  purchasePrice;
  
  /// Quantidade de tokens possuída pelo investidor na carteira.
  final int                      tokenQuantity;
  
  /// Valor de mercado total da custódia do usuário (quantidade * preço atual).
  final double                   totalValue;
  
  /// Snapshots contendo as cotações históricas na janela de tempo selecionada.
  final List<PriceSnapshotModel> snapshots;

  const TokenHistoryModel({
    required this.currentPrice,
    required this.purchasePrice,
    required this.tokenQuantity,
    required this.totalValue,
    required this.snapshots,
  });

  /// Cria o histórico de tokens a partir da resposta HTTP Callable.
  factory TokenHistoryModel.fromMap(Map<String, dynamic> map) {
    final raw = (map['snapshots'] as List<dynamic>?) ?? [];
    return TokenHistoryModel(
      currentPrice:  (map['currentPrice']  as num).toDouble(),
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble(),
      tokenQuantity: (map['tokenQuantity'] as num?)?.toInt()    ?? 0,
      totalValue:    (map['totalValue']    as num?)?.toDouble() ?? 0.0,
      snapshots: raw
          .map((s) => PriceSnapshotModel.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList(),
    );
  }

  /// Indica se o investidor logado possui investimento ativo.
  bool get hasInvestment => purchasePrice != null;

  /// Retorna a cotação registrada no início do período temporal carregado (primeiro snapshot).
  /// Caso a lista esteja vazia, retorna a cotação atual como fallback.
  double get periodStartPrice =>
      snapshots.isNotEmpty ? snapshots.first.price : currentPrice;

  /// Retorna a variação percentual de valorização/desvalorização do ativo no período temporal selecionado.
  double get changePercent {
    if (periodStartPrice == 0) return 0;
    return ((currentPrice - periodStartPrice) / periodStartPrice) * 100;
  }
}
