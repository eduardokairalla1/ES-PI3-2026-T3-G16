import 'package:firebase_auth/firebase_auth.dart';
import 'package:mesclainvest/pages/profile/models/profile_data.dart';

class ProfileService {
  Future<ProfileData> fetchProfileData() async {
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
