/// Modelo de dados usado na tela de perfil.
///
/// Mantém informações já prontas para exibição na UI.
class ProfileData {
  /// Nome exibido no cabeçalho de usuário.
  final String name;

  /// E-mail principal da conta.
  final String email;

  /// Quantidade de investimentos exibida no card.
  final String investments;

  /// Valor aplicado exibido no card de estatísticas.
  final String investedAmount;

  /// Quantidade de startups favoritas.
  final String favorites;

  const ProfileData({
    required this.name,
    required this.email,
    required this.investments,
    required this.investedAmount,
    required this.favorites,
  });
}

