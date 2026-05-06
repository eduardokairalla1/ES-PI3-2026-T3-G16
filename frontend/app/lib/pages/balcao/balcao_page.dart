import 'package:flutter/material.dart';
import 'package:mesclainvest/pages/balcao/controllers/balcao_controller.dart';
import 'package:mesclainvest/pages/balcao/widgets/balcao_skeleton.dart';
import 'package:mesclainvest/pages/dashboard/widgets/meus_investimentos.dart';
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
              GestureDetector(
                onTap: _controller.load,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Tentar novamente',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
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

    return RefreshIndicator(
      color: Colors.black,
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: MeusInvestimentos(portfolio: _controller.portfolio),
      ),
    );
  }
}
