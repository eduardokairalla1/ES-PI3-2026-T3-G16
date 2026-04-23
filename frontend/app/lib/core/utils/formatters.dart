/// --- Utilitários de Formatação ---

import 'package:intl/intl.dart';

/// Eu forneço extensões para formatar tipos básicos em strings legíveis.
extension CurrencyFormatter on double {

  /// Eu formato um double para o padrão de moeda brasileiro (BRL).
  String toBRL() {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: r'R$',
    ).format(this);
  }

}
