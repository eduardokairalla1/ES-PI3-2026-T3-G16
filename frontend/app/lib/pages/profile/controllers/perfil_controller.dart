import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/profile/models/perfil_data.dart';
import 'package:mesclainvest/pages/profile/services/perfil_service.dart';

/// [PerfilController] centraliza a lógica de negócio e o estado da tela de Perfil.
/// Ele estende [ChangeNotifier] para permitir que a UI reaja a mudanças de estado.
class PerfilController extends ChangeNotifier {
  
  // Instância do serviço que lida com o fetching de dados (atualmente mockado).
  final PerfilService _service = PerfilService();

  // Flag que indica se a tela está carregando dados iniciais.
  bool isLoading = true;

  // Estado das configurações de segurança (2FA).
  bool autenticacao2FA = true;

  // Estado da preferência de tema do usuário.
  bool modoEscuro = false;
  
  // Objeto que contém as informações reais do perfil do usuário.
  PerfilData? data;

  /// Método chamado para iniciar o ciclo de vida do controlador e carregar dados.
  Future<void> inicializar() async {
    isLoading = true;
    notifyListeners(); // Notifica a UI para mostrar o carregamento.

    try {
      // Busca os dados através do serviço.
      data = await _service.fetchPerfilData();
    } catch (e) {
      // Em um app real, aqui trataríamos erros de conexão ou permissão.
      debugPrint('Erro ao carregar perfil: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // Notifica que o carregamento terminou.
    }
  }

  /// Alterna o estado da autenticação em duas etapas.
  void toggle2FA(bool value) {
    autenticacao2FA = value;
    notifyListeners();
  }

  /// Alterna a preferência de tema (Claro/Escuro).
  void toggleModoEscuro(bool value) {
    modoEscuro = value;
    notifyListeners();
  }

  /// Executa o processo de encerramento de sessão.
  void logout() {
    // Por enquanto apenas loga no console, futuramente integrará com o Firebase Auth.
    debugPrint('Saindo da conta...');
  }
}
