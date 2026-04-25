import 'package:mesclainvest/pages/profile/models/perfil_data.dart';

/// Provê acesso aos dados do perfil (atualmente mockados).
class PerfilService {
  
  /// Busca os dados do perfil do usuário.
  Future<PerfilData> fetchPerfilData() async {
    // Simula um delay de rede.
    await Future.delayed(const Duration(milliseconds: 500));

    return PerfilData(
      nome: '*NOME*',
      email: '*email@email.com*',
      investimentos: '99',
      aplicado: 'R\$9,99',
      favoritas: '9',
    );
  }
}
