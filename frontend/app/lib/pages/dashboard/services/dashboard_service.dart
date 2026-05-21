/*
 * Service do Dashboard.
 * Encapsula as chamadas às Cloud Functions usadas pela tela de Dashboard.
 *
 * Alex Gabriel Soares Sousa - 24802449
 */
library;

/*
 * IMPORTS
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mesclainvest/pages/dashboard/models/dashboard_data.dart';

/*
 * CODE
 */

/// Serviço que encapsula a integração com o Firebase Cloud Functions para a tela de Dashboard.
/// Realiza chamadas remotas de funções callable no backend para ler e modificar dados do usuário.
class DashboardService {
  // Instância do Firebase Functions configurada no aplicativo
  final _functions = FirebaseFunctions.instance;

  /// Consulta os dados consolidados do painel do usuário através da Cloud Function `onGetDashboard`.
  /// Retorna uma instância de [DashboardData] com saldos, patrimônio e listas associadas.
  Future<DashboardData> fetchUserDashboardData() async {
    final result = await _functions
        .httpsCallable('onGetDashboard')
        .call<Map<String, dynamic>>();

    return DashboardData.fromMap(Map<String, dynamic>.from(result.data));
  }

  /// Alterna a marcação de favorita de uma startup através da Cloud Function `onToggleFavorite`.
  /// Retorna o novo estado lógico de favorito (`true` se marcada, `false` se desmarcada).
  Future<bool> toggleFavorite(String startupId) async {
    final result = await _functions
        .httpsCallable('onToggleFavorite')
        .call<Map<String, dynamic>>({'startupId': startupId});

    return (result.data as Map)['isFavorited'] as bool;
  }

  /// Realiza uma requisição de depósito simulado por meio da Cloud Function `onDeposit`.
  /// Retorna o saldo da carteira atualizado.
  Future<double> deposit(double amount) async {
    final result = await _functions
        .httpsCallable('onDeposit')
        .call<Map<String, dynamic>>({'amount': amount});

    return (result.data['newBalance'] as num).toDouble();
  }

  /// Busca o histórico consolidado de transações da carteira do usuário pela Cloud Function `onGetTransactions`.
  /// Retorna uma lista contendo mapas de dados representando cada transação (depósitos, compras e vendas de tokens).
  Future<List<Map<String, dynamic>>> getTransactions({int limit = 20}) async {
    final result = await _functions
        .httpsCallable('onGetTransactions')
        .call<Map<String, dynamic>>({'limit': limit});

    final List<dynamic> list = result.data['transactions'] ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Busca o histórico de evolução patrimonial real do usuário pela Cloud Function `onGetPatrimonyHistory`.
  /// Retorna os pontos do histórico do patrimônio do usuário.
  Future<List<Map<String, dynamic>>> fetchPatrimonyHistory(String period) async {
    final result = await _functions
        .httpsCallable('onGetPatrimonyHistory')
        .call<Map<String, dynamic>>({'period': period});

    final List<dynamic> list = result.data['history'] ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
