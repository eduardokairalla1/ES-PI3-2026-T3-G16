/*
 * Modelo de um item do portfolio do usuário.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

/// Modelo que representa um ativo individual sob a custódia do investidor logado.
class PortfolioItemModel {
  /// Identificador único (Doc ID no Firestore) da startup emissora do token.
  final String  startupId;
  
  /// Nome de exibição da startup.
  final String  startupName;
  
  /// URL contendo a imagem do logotipo da startup (opcional).
  final String? logoUrl;
  
  /// Estágio de captação ou maturidade da startup (ex: 'new', 'operating').
  final String  stage;
  
  /// Slogan de apresentação rápida da startup.
  final String tagline;
  
  /// Preço unitário atual de negociação do token.
  final double tokenPrice;
  
  /// Quantidade total de tokens sob a posse do usuário.
  final int    tokenQuantity;
  
  /// Valor total consolidado do investimento (quantidade * preço unitário atual).
  final double totalValue;
  
  /// Preço médio de compra ponderado pago pelos tokens.
  final double purchasePrice;
  
  /// Variação percentual ponderada de valorização/desvalorização do ativo em relação ao preço médio de compra.
  final double changePercent;

  const PortfolioItemModel({
    required this.startupId,
    required this.startupName,
    this.logoUrl,
    required this.stage,
    required this.tagline,
    required this.tokenPrice,
    required this.tokenQuantity,
    required this.totalValue,
    required this.purchasePrice,
    required this.changePercent,
  });

  /// Indica se o rendimento acumulado da custódia deste ativo é positivo (lucro ou estabilidade).
  bool get isPositive => changePercent >= 0;

  /// Cria uma entidade de custódia [PortfolioItemModel] mapeando dados decodificados da Cloud Function.
  factory PortfolioItemModel.fromMap(Map<String, dynamic> map) {
    return PortfolioItemModel(
      startupId:     map['startupId']     as String,
      startupName:   map['startupName']   as String,
      logoUrl:       map['logoUrl']       as String?,
      stage:         map['stage']         as String,
      tagline:       map['tagline']       as String,
      tokenPrice:    (map['tokenPrice']    as num).toDouble(),
      tokenQuantity: (map['tokenQuantity'] as num).toInt(),
      totalValue:    (map['totalValue']    as num).toDouble(),
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      changePercent: (map['changePercent'] as num).toDouble(),
    );
  }
}
