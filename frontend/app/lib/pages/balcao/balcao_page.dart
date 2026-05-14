import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/balcao/controllers/balcao_controller.dart';
import 'package:mesclainvest/pages/balcao/widgets/balcao_skeleton.dart';
import 'package:mesclainvest/pages/dashboard/models/portfolio_item_model.dart';
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
    return AnimatedBuilder(
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
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balcão',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Seus investimentos em startups',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
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

    if (_controller.portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 48, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              'Você ainda não tem investimentos.\nExplore as startups disponíveis!',
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
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _controller.portfolio.length,
        itemBuilder: (context, index) {
          final item = _controller.portfolio[index];
          return _PortfolioCard(item: item, currencyFmt: currencyFmt);
        },
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
