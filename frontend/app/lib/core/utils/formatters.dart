/// --- Utilitários de Formatação ---

import 'package:intl/intl.dart';

/// Eu forneço extensões para formatar tipos básicos em strings legíveis.
extension CurrencyFormatter on double {

  /// Eu formato um double para o padrão de moeda brasileiro (BRL).
  String toBRL() {
    final format = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: r'R$',
    );
    // Removemos o espaço que o NumberFormat insere por padrão entre o símbolo e o valor
    return format.format(this).replaceFirst(r'R$ ', r'R$');
  }

}
