import 'package:flutter/material.dart';
import 'package:mesclainvest/shared/widgets/shimmer_box.dart';

class BalcaoSkeleton extends StatelessWidget {

  const BalcaoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(4, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              const ShimmerBox(width: 48, height: 48, borderRadius: BorderRadius.all(Radius.circular(24))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: double.infinity, height: 15, borderRadius: BorderRadius.circular(6)),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 12, borderRadius: BorderRadius.circular(6)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerBox(width: 80, height: 15, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 48, height: 12, borderRadius: BorderRadius.circular(6)),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }
}
