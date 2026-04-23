/// --- Widget Base para Cards ---

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/portfolio/widgets/portfolio_styles.dart';

/// Eu represento a estrutura base de um cartão na tela de portfólio.
/// Isso evita a repetição de BoxDecoration e Paddings.
class CartaoBase extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const CartaoBase({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      padding: padding ?? PortfolioStyles.cardPadding,
      decoration: PortfolioStyles.cardDecoration,
      child: child,
    );
  }
}
