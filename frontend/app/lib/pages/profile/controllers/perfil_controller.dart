import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/profile/models/perfil_data.dart';
import 'package:mesclainvest/pages/profile/services/perfil_service.dart';

/// Gerencia o estado e a lógica da tela de Perfil.
class PerfilController extends ChangeNotifier {
  
  // Dependências.
  final PerfilService _service = PerfilService();

  // Estado da UI.
  bool isLoading = true;
  bool autenticacao2FA = true;
  bool modoEscuro = false;
  
  // Dados do perfil.
  PerfilData? data;

  /// Inicializa o controlador e carrega os dados.
  Future<void> inicializar() async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _service.fetchPerfilData();
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Alterna o estado da autenticação 2FA.
  void toggle2FA(bool value) {
    autenticacao2FA = value;
    notifyListeners();
  }

  /// Alterna entre modo claro e escuro.
  void toggleModoEscuro(bool value) {
    modoEscuro = value;
    notifyListeners();
  }

  /// Realiza a saída do usuário da conta.
  void logout() {
    debugPrint('Saindo da conta...');
  }
}
