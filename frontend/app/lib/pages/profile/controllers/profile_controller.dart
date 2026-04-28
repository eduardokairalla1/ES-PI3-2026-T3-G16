import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/profile/models/profile_data.dart';
import 'package:mesclainvest/pages/profile/services/profile_service.dart';

/// Controlador da feature de perfil.
///
/// Centraliza estado de carregamento, preferências visuais locais
/// e dados do usuário exibidos na tela.
class ProfileController extends ChangeNotifier {
  /// Serviço responsável por buscar os dados de perfil.
  final ProfileService _service = ProfileService();

  /// Indica se a tela ainda está carregando os dados iniciais.
  bool isLoading = true;

  /// Estado local do switch de autenticação em duas etapas.
  bool twoFactorEnabled = true;

  /// Estado local do switch de modo escuro.
  bool darkModeEnabled = false;

  /// Dados de perfil carregados para renderização da UI.
  ProfileData? data;

  /// Inicializa o controlador carregando dados do perfil.
  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _service.fetchProfileData();
    } catch (error) {
      debugPrint('Falha ao carregar perfil: $error');
    }

    isLoading = false;
    notifyListeners();
  }

  /// Atualiza o estado da opção de 2FA.
  void setTwoFactor(bool value) {
    twoFactorEnabled = value;
    notifyListeners();
  }

  /// Atualiza o estado da opção de modo escuro.
  void setDarkMode(bool value) {
    darkModeEnabled = value;
    notifyListeners();
  }

  /// Encerra a sessão do usuário autenticado.
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}

