/// Representa os dados consolidados do perfil do usuário.
class PerfilData {
  final String nome;
  final String email;
  final String investimentos;
  final String aplicado;
  final String favoritas;

  PerfilData({
    required this.nome,
    required this.email,
    required this.investimentos,
    required this.aplicado,
    required this.favoritas,
  });
}
