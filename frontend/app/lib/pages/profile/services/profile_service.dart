import 'package:firebase_auth/firebase_auth.dart';
import 'package:mesclainvest/pages/profile/models/profile_data.dart';

/// Serviço de dados do perfil.
///
/// Hoje retorna dados simples (com parte mockada), mas já concentra
/// a origem da informação para facilitar evolução futura.
class ProfileService {
  /// Busca os dados de perfil para a tela.
  Future<ProfileData> fetchProfileData() async {
    // Simula latência de rede.
    await Future.delayed(const Duration(milliseconds: 500));

    final user = FirebaseAuth.instance.currentUser;

    return ProfileData(
      name: user?.displayName ?? 'Usuario Mescla',
      email: user?.email ?? 'carregando...',
      investments: '0',
      investedAmount: 'R\$ 0,00',
      favorites: '0',
    );
  }
}

