/// Modelo de um item do portfolio do usuário.

class PortfolioItemModel {
  final String  startupId;
  final String  startupName;
  final String? logoUrl;
  final String  stage;
  final String tagline;
  final double tokenPrice;
  final int    tokenQuantity;
  final double totalValue;
  final double purchasePrice;
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

  bool get isPositive => changePercent >= 0;

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
