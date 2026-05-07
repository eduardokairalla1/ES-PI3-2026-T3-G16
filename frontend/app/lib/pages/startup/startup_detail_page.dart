/// Eduardo Kairalla - 24024241

/// Startup detail screen — tabs: About, Partners, Q&A, Video.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_controller.dart';
import 'package:mesclainvest/pages/startup/widgets/widgets.dart';


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
            backgroundColor: const Color(0xFFF8F8F8),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _controller.load(widget.startupId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final startup  = _controller.startup!;
        final userName = AppState.instance.profile?.fullName ?? 'Usuário';

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F8F8),
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
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.black, width: 2.5),
                        insets: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(icon: Icon(Icons.info_outline,        size: 18), text: 'Sobre'),
                        Tab(icon: Icon(Icons.people_outline,      size: 18), text: 'Sócios'),
                        Tab(icon: Icon(Icons.chat_bubble_outline, size: 18), text: 'Q&A'),
                        Tab(icon: Icon(Icons.play_circle_outline, size: 18), text: 'Vídeo'),
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
                            startupId:  widget.startupId,
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

  Widget _investButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _controller.openOrderPanel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'INVESTIR NESTA STARTUP',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderPanel(
    BuildContext context,
    NumberFormat formatter,
    double total,
  ) {
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

          Text(
            'Investir em ${_controller.startup?.name ?? ''}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                      'Qtd atual: ${_controller.orderQuantity}',
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
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _controller.isBuyingTokens
                  ? null
                  : () async {
                      final ok = await _controller.buyTokens(_startupId);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Investimento realizado com sucesso!'),
                            backgroundColor: Colors.black,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _controller.isBuyingTokens
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'CONFIRMAR INVESTIMENTO',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          GestureDetector(
            onTap: _controller.closeOrderPanel,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
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
