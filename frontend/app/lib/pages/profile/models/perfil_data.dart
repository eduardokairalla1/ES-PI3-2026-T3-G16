/// [PerfilData] é um modelo de dados (Data Class) que representa as informações consolidadas
/// do perfil de um usuário no sistema MesclaInvest.
/// 
/// Ele é utilizado para transferir dados de forma estruturada entre o serviço e a UI.
class PerfilData {
  final String nome;          // Nome completo ou apelido do usuário.
  final String email;         // Endereço de e-mail principal.
  final String investimentos; // Quantidade total de startups/tokens na carteira.
  final String aplicado;      // Valor monetário total investido (formatado como String).
  final String favoritas;     // Quantidade de startups marcadas como favoritas.

  PerfilData({
    required this.nome,
    required this.email,
    required this.investimentos,
    required this.aplicado,
    required this.favoritas,
  });
}
