// Eduardo Kairalla - 24024241

// Startup detail screen — tabs: About, Partners, Q&A, Video.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_controller.dart';
import 'package:mesclainvest/pages/startup/widgets/widgets.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';
import 'package:mesclainvest/shared/styles/money_style.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- PAGE ---

/// I display the full startup detail screen with tabs for About, Partners, Q&A, and Video.
class StartupDetailPage extends StatefulWidget {
  final String startupId;

  const StartupDetailPage({super.key, required this.startupId});

  @override
  State<StartupDetailPage> createState() => _StartupDetailPageState();
}

/// State for StartupDetailPage.
class _StartupDetailPageState extends State<StartupDetailPage> {
  final StartupController _controller = StartupController();

  @override
  void initState() {
    super.initState();
    _controller.load(widget.startupId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground(context),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.textPrimary(context)),
            ),
          );
        }

        if (_controller.errorMessage != null) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground(context),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.textMuted(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Tentar novamente',
                    size: AppButtonSize.small,
                    fullWidth: false,
                    onPressed: () => _controller.load(widget.startupId),
                  ),
                ],
              ),
            ),
          );
        }

        final startup = _controller.startup!;

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: AppColors.pageBackground(context),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  StartupHeader(startup: startup),

                  StartupInfoCard(startup: startup),

                  Divider(height: 1, thickness: 1, color: AppColors.border(context)),

                  Container(
                    color: AppColors.surfaceColor(context),
                    child: TabBar(
                      labelColor: AppColors.textPrimary(context),
                      unselectedLabelColor: AppColors.textMuted(context),
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(color: AppColors.textPrimary(context), width: 2.5),
                        insets: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.info_outline, size: 18),
                          text: 'Sobre',
                        ),
                        Tab(
                          icon: Icon(Icons.people_outline, size: 18),
                          text: 'Sócios',
                        ),
                        Tab(
                          icon: Icon(Icons.chat_bubble_outline, size: 18),
                          text: 'Q&A',
                        ),
                        Tab(
                          icon: Icon(Icons.play_circle_outline, size: 18),
                          text: 'Vídeo',
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        AboutTab(startup: startup),
                        PartnersTab(startup: startup),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) => QATab(
                            controller: _controller,
                            startupId: widget.startupId,
                          ),
                        ),
                        VideoTab(videoUrl: startup.videoUrl),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            bottomNavigationBar: SafeArea(
              child: _InvestPanel(
                controller: _controller,
                startupId: widget.startupId,
              ),
            ),
          ),
        );
      },
    );
  }
}


// --- INVEST PANEL ---

/// I manage the bottom invest panel that expands into a token quantity selector.
class _InvestPanel extends StatefulWidget {
  final StartupController controller;
  final String startupId;

  const _InvestPanel({
    required this.controller,
    required this.startupId,
  });

  @override
  State<_InvestPanel> createState() => _InvestPanelState();
}

/// State for _InvestPanel.
class _InvestPanelState extends State<_InvestPanel> {
  final _qtyCtrl = TextEditingController(text: '1');
  bool _syncingFromController = false;

  StartupController get _controller => widget.controller;
  String get _startupId => widget.startupId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _qtyCtrl.addListener(_onFieldChanged);
  }

  void _onControllerChanged() {
    final expected = '${_controller.orderQuantity}';
    if (_qtyCtrl.text != expected) {
      _syncingFromController = true;
      _qtyCtrl.value = _qtyCtrl.value.copyWith(
        text: expected,
        selection: TextSelection.collapsed(offset: expected.length),
      );
      _syncingFromController = false;
    }
  }

  void _onFieldChanged() {
    if (_syncingFromController) return;
    final val = int.tryParse(_qtyCtrl.text);
    if (val == null) return;
    final clamped = val.clamp(1, 10000);
    if (clamped != _controller.orderQuantity) {
      _controller.setOrderQuantity(clamped);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final startup   = _controller.startup;
        final price     = startup?.tokenPrice ?? 0.0;
        final total     = price * _controller.orderQuantity;
        final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

        return AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
          child: _controller.showOrderPanel
              ? _orderPanel(context, formatter, total)
              : _investButton(),
        );
      },
    );
  }

  /// I build the collapsed invest button shown when the order panel is closed.
  Widget _investButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: AppButton(
        label: 'INVESTIR NESTA STARTUP',
        onPressed: _controller.openOrderPanel,
      ),
    );
  }

  /// I build the expanded order panel with a quantity stepper and confirm button.
  Widget _orderPanel(
    BuildContext context,
    NumberFormat formatter,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Investir em ${_controller.startup?.name ?? ''}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 20),

          // quantity stepper
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _stepperButton(
                    icon: Icons.remove,
                    onTap: _controller.decrementOrder,
                  ),
                  const SizedBox(width: 28),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  _stepperButton(
                    icon: Icons.add,
                    onTap: _controller.incrementOrder,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'máx. 10.000 tokens',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // total cost row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valor Total:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Text(
                  formatter.format(total),
                  style: moneyStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),

          if (_controller.buyErrorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.buyErrorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ],

          const SizedBox(height: 14),

          // confirm + cancel buttons
          AppButton(
            label: 'CONFIRMAR INVESTIMENTO',
            isLoading: _controller.isBuyingTokens,
            onPressed: () async {
              final ok = await _controller.buyTokens(_startupId);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Investimento realizado com sucesso!'),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 8),

          AppButton(
            label: 'Cancelar',
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
            onPressed: _controller.closeOrderPanel,
          ),

        ],
      ),
    );
  }

  /// I build a stepper increment or decrement button.
  Widget _stepperButton({required IconData icon, required VoidCallback onTap}) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary(context)),
        ),
      ),
    );
  }
}
