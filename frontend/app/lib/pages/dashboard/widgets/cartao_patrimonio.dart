/*
 * Widget do Cartão de Patrimônio do Dashboard.
 * Exibe o saldo total, rendimento diário e saldo disponível na carteira do investidor.
 *
 * É o principal ponto de foco financeiro da Home, resumindo a custódia do usuário.
 * Oferece um botão para ligar/desligar a visibilidade dos saldos (olho aberto/fechado),
 * aplicando uma máscara visual aos valores sensíveis caso o usuário queira privacidade.
 * Renderiza tendências de rentabilidade diária com variações nominais (R$) e percentuais (%),
 * usando esquemas de cores semânticos (verde para alta e vermelho para queda).
 *
 * Alex Gabriel Soares Sousa - 24802449
 */

library;

/*
 * IMPORTS
 */

import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:intl/intl.dart';

/*
 * CODE
 */

/// Exibição visual do patrimônio consolidado e rendimentos.
/// Consome propriedades do [DashboardController] e reage a mudanças na visibilidade dos valores.
class CartaoPatrimonio extends StatelessWidget {
  /// Controlador que fornece dados financeiros atualizados e gerencia a visibilidade dos saldos.
  final DashboardController controller;

  /// Construtor principal associado ao controller.
  const CartaoPatrimonio({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Formatador de moeda brasileira (Padrão de localização BRL: R$ XX.XXX,XX)
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Extração direta dos dados e estado de visibilidade
    final data = controller.data;
    final bool visivel = controller.exibirValores;

    // Retorna um widget vazio caso os dados do Dashboard ainda não estejam carregados
    if (data == null) return const SizedBox();

    // Formatação prévia dos saldos e rendimentos diários
    final String valPatrimonio = formatter.format(data.patrimonioTotal);
    final String valLucroDiario = formatter.format(data.rendimentoDiarioValor);
    final String valLucroPorcentagem = data.rendimentoDiarioPorcentagem.toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Título: MEU PATRIMÔNIO ---
          Text(
            'MEU PATRIMÔNIO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary(context),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          // --- Valor do Patrimônio e Controle de Visibilidade ---
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  visivel ? valPatrimonio : 'R\$ *********',
                  key: ValueKey<bool>(visivel),
                  style: moneyStyle(
                    fontSize: 24,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              const Spacer(),
              // Botão para ocultar/mostrar valores
              GestureDetector(
                onTap: controller.toggleVisibility,
                child: Tooltip(
                  message: visivel ? 'Ocultar saldo' : 'Mostrar saldo',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      visivel
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // --- Rentabilidade Diária ---
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: visivel ? 1.0 : 0.5,
            child: Row(
              children: [
                Icon(
                  data.rendimentoDiarioValor >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: visivel
                      ? (data.rendimentoDiarioValor >= 0
                            ? Colors.green
                            : Colors.red)
                      : AppColors.textMuted(context),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  visivel
                      ? '${data.rendimentoDiarioValor >= 0 ? '+' : ''}$valLucroDiario'
                      : '*******',
                  style: moneyStyle(
                    fontSize: 14,
                    color: visivel
                        ? (data.rendimentoDiarioValor >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700)
                        : AppColors.textMuted(context),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  visivel
                      ? '(${data.rendimentoDiarioPorcentagem >= 0 ? '+' : ''}$valLucroPorcentagem%) hoje'
                      : '(****) ****',
                  style: TextStyle(
                    fontSize: 14,
                    color: visivel ? AppColors.textSecondary(context) : AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 32, thickness: 1, color: AppColors.borderSoft(context)),

          // --- Saldo Disponível na Carteira (Wallet) ---
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SALDO DISPONÍVEL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visivel
                        ? formatter.format(data.saldoDisponivel)
                        : 'R\$ ****',
                    style: moneyStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
