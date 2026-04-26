import 'package:mesclainvest/pages/profile/models/perfil_data.dart';

/// [PerfilService] é responsável por centralizar todas as chamadas de API ou
/// interações com o banco de dados relacionadas ao perfil do usuário.
class PerfilService {
  
  /// Busca os dados do perfil do usuário de forma assíncrona.
  /// 
  /// No momento, este método utiliza dados estáticos (Mock) para simular o comportamento
  /// de uma API real, incluindo um atraso proposital de 500ms para testar indicadores de carregamento.
  Future<PerfilData> fetchPerfilData() async {
    // Simula o tempo de resposta de uma rede real.
    await Future.delayed(const Duration(milliseconds: 500));

    // Retorna uma instância de PerfilData com valores fictícios baseados no design.
    return PerfilData(
      nome: '*NOME*',
      email: '*email@email.com*',
      investimentos: '99',
      aplicado: 'R$9,99',
      favoritas: '9',
    );
  }
}
