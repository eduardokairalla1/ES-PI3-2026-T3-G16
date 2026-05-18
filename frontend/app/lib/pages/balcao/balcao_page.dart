import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/balcao/controllers/balcao_controller.dart';
import 'package:mesclainvest/pages/balcao/widgets/balcao_skeleton.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
import 'package:mesclainvest/pages/dashboard/models/pending_order_model.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/pages/balcao/widgets/edit_order_dialog.dart';
import 'package:mesclainvest/shared/widgets/app_button.dart';
import 'package:mesclainvest/shared/widgets/bottom_nav.dart';
import 'package:mesclainvest/shared/widgets/delayed_shimmer.dart';

class BalcaoPage extends StatefulWidget {

  const BalcaoPage({super.key});

  @override
  State<BalcaoPage> createState() => _BalcaoPageState();
}

class _BalcaoPageState extends State<BalcaoPage> {

  final BalcaoController _controller = BalcaoController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      'Investimentos',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black38,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(color: Colors.black, width: 2.5),
                      insets: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'Mercado'),
                      Tab(text: 'Meus Investimentos'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: DelayedShimmer(
                      isLoading: _controller.isLoading,
                      skeleton: const BalcaoSkeleton(),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const SafeArea(
              child: BottomNav(currentIndex: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.black26),
              const SizedBox(height: 16),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Tentar novamente',
                size: AppButtonSize.small,
                fullWidth: false,
                onPressed: _controller.load,
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      children: [
        _buildMercadoTab(),
        _buildInvestmentsTab(),
      ],
    );
  }

  Widget _buildInvestmentsTab() {
    if (_controller.portfolio.isEmpty && _controller.pendingOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 48, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              'Você ainda não tem investimentos.\nExplore as startups no Mercado!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final currencyFmt = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return RefreshIndicator(
      color: Colors.black,
      onRefresh: _controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (_controller.portfolio.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 4),
              child: Text('Ativos na Carteira', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ..._controller.portfolio.map((item) => _PortfolioCard(item: item, currencyFmt: currencyFmt)),
            const SizedBox(height: 16),
          ],
          
          if (_controller.pendingOrders.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 4),
              child: Text('Ofertas Pendentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ..._controller.pendingOrders.map((order) => _PendingOrderCard(
              order: order, 
              currencyFmt: currencyFmt,
              onEdit: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => EditOrderDialog(order: order),
                );
                if (result == true) {
                  _controller.load(); // Reload data after successful edit
                }
              },
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildMercadoTab() {
    if (_controller.startups.isEmpty) {
      return const Center(child: Text('Nenhuma startup encontrada no mercado.'));
    }

    final currencyFmt = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return RefreshIndicator(
      color: Colors.black,
      onRefresh: _controller.load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _controller.startups.length,
        itemBuilder: (context, index) {
          final startup = _controller.startups[index];
          return _StartupMarketCard(startup: startup, currencyFmt: currencyFmt);
        },
      ),
    );
  }
}

class _StartupMarketCard extends StatelessWidget {
  final StartupModel startup;
  final NumberFormat currencyFmt;

  const _StartupMarketCard({required this.startup, required this.currencyFmt});

  @override
  Widget build(BuildContext context) {
    final logoUrl = startup.logoUrl ?? '';

    return GestureDetector(
      onTap: () => context.push('/balcao/orderbook/${startup.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                image: logoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: logoUrl.isEmpty
                  ? Center(
                      child: Text(
                        startup.name.isNotEmpty
                            ? startup.name[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startup.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tokens Livres: ${NumberFormat.decimalPattern('pt_BR').format(startup.totalTokens)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFmt.format(startup.tokenPrice),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Preço base',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final PortfolioItemModel item;
  final NumberFormat currencyFmt;

  const _PortfolioCard({required this.item, required this.currencyFmt});

  @override
  Widget build(BuildContext context) {
    final logoUrl = item.logoUrl ?? '';

    return GestureDetector(
      onTap: () => context.push('/startup/${item.startupId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                image: logoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: logoUrl.isEmpty
                  ? Center(
                      child: Text(
                        item.startupName.isNotEmpty
                            ? item.startupName[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.startupName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${NumberFormat.decimalPattern('pt_BR').format(item.tokenQuantity)} STX',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFmt.format(item.totalValue),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.isPositive
                        ? Colors.green.shade700.withValues(alpha: 0.1)
                        : Colors.red.shade700.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.isPositive ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: item.isPositive
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PendingOrderCard extends StatelessWidget {
  final PendingOrderModel order;
  final NumberFormat currencyFmt;
  final VoidCallback onEdit;

  const _PendingOrderCard({required this.order, required this.currencyFmt, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final logoUrl = order.logoUrl;
    final isBuy = order.type == 'buy';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isBuy ? Colors.green.shade200 : Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
              image: logoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(logoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: logoUrl.isEmpty
                ? Center(
                    child: Text(
                      order.startupName.isNotEmpty
                          ? order.startupName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.startupName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isBuy ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isBuy ? 'COMPRA' : 'VENDA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isBuy ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat.decimalPattern('pt_BR').format(order.quantity)} STX a ${currencyFmt.format(order.price)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue.shade600, size: 22),
            onPressed: onEdit,
            tooltip: 'Editar Ordem',
          ),
        ],
      ),
    );
  }
}
