import 'package:flutter/material.dart';
import 'package:mesclainvest/shared/widgets/shimmer_box.dart';

class DashboardSkeleton extends StatelessWidget {

  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cabecalho
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const ShimmerBox(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 14, borderRadius: BorderRadius.circular(6)),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 80, height: 11, borderRadius: BorderRadius.circular(6)),
                  ],
                ),
              ],
            ),
          ),

          // cartao patrimonio
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 100, height: 11, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 14),
                ShimmerBox(width: 180, height: 28, borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 10),
                ShimmerBox(width: 140, height: 14, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 20),
                Divider(height: 1, color: Colors.grey.shade100),
              ],
            ),
          ),

          // botoes acao
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(child: ShimmerBox(width: double.infinity, height: 48, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 12),
                Expanded(child: ShimmerBox(width: double.infinity, height: 48, borderRadius: BorderRadius.circular(12))),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // startups card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ShimmerBox(width: 140, height: 11, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 16),
                ..._buildRows(4),
                const SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 44, borderRadius: BorderRadius.circular(12)),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildRows(int count) {
    return List.generate(count, (_) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const ShimmerBox(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(22))),
          const SizedBox(width: 14),
          Expanded(child: ShimmerBox(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(6))),
          const SizedBox(width: 16),
          ShimmerBox(width: 70, height: 16, borderRadius: BorderRadius.circular(6)),
        ],
      ),
    ));
  }
}
