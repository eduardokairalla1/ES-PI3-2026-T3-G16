// Eduardo Kairalla - 24024241

// Startup detail screen — tabs: About, Partners, Q&A, Video.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_controller.dart';
import 'package:mesclainvest/pages/startup/widgets/widgets.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';

// --- PAGE ---

class StartupDetailPage extends StatefulWidget {
  final String startupId;

  const StartupDetailPage({super.key, required this.startupId});

  @override
  State<StartupDetailPage> createState() => _StartupDetailPageState();
}

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
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        if (_controller.errorMessage != null) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
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
        final userName = AppState.instance.profile?.fullName ?? 'Usuário';

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  StartupHeader(startup: startup, userName: userName),

                  StartupInfoCard(startup: startup),

                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                  Container(
                    color: Colors.white,
                    child: TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black38,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.black, width: 2.5),
                        insets: EdgeInsets.symmetric(horizontal: 16),
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

class _InvestPanel extends StatelessWidget {

  final StartupController _controller;
  final String            _startupId;

  const _InvestPanel({
    required StartupController controller,
    required String            startupId,
  })  : _controller = controller,
        _startupId  = startupId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final startup   = _controller.startup;
        final total     = _controller.orderPrice * _controller.orderQuantity;
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

  Widget _investButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: AppButton(
        label: 'NOVA ORDEM (COMPRA/VENDA)',
        onPressed: _controller.openOrderPanel,
      ),
    );
  }

  Widget _orderPanel(
    BuildContext context,
    NumberFormat formatter,
    double total,
  ) {
    final isBuy = _controller.orderType == 'buy';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _controller.setOrderType('buy'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isBuy ? Colors.green.shade600 : Colors.grey.shade100,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                    ),
                    child: Text('COMPRAR', textAlign: TextAlign.center, style: TextStyle(color: isBuy ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _controller.setOrderType('sell'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !isBuy ? Colors.red.shade600 : Colors.grey.shade100,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                    ),
                    child: Text('VENDER', textAlign: TextAlign.center, style: TextStyle(color: !isBuy ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // quantity stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepperButton(
                icon: Icons.remove,
                onTap: _controller.decrementOrder,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      '${_controller.orderQuantity}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Quantidade',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              _stepperButton(
                icon: Icons.add,
                onTap: _controller.incrementOrder,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Preço Limite (R\$):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: _controller.orderPrice.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (val) {
                      final parsed = double.tryParse(val.replaceAll(',', '.'));
                      if (parsed != null && parsed > 0) {
                        _controller.setOrderPrice(parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),

          // total cost row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
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
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  formatter.format(total),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
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
            label: isBuy ? 'ENVIAR ORDEM DE COMPRA' : 'ENVIAR ORDEM DE VENDA',
            isLoading: _controller.isBuyingTokens,
            onPressed: () async {
              final ok = await _controller.placeOrder(_startupId);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ordem de ${isBuy ? 'compra' : 'venda'} enviada com sucesso!'),
                    backgroundColor: Colors.black,
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

  Widget _stepperButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
