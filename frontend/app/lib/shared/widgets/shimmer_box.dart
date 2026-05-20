// Pedro Henrique Medeiros dos Reis - 24801656
// Shimmer is now theme-aware: lighter greys for light mode, darker greys for
// dark mode. Without this the skeleton becomes invisible on the dark
// background.

import 'package:flutter/material.dart';

/// Animated placeholder used as a skeleton while real content is loading.
///
/// Paints a fixed-size box with a horizontally sweeping gradient. The base
/// and highlight colours adapt to the active brightness so the shimmer stays
/// visible in both light and dark mode.
class ShimmerBox extends StatefulWidget {

  /// Fixed width of the placeholder, in logical pixels.
  final double width;

  /// Fixed height of the placeholder, in logical pixels.
  final double height;

  /// Corner radius applied to the placeholder; defaults to a soft 8px rounding.
  final BorderRadius borderRadius;

  /// Creates a shimmer placeholder of the given [width] and [height].
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base       = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFEEEEEE);
    final highlight  = isDark ? const Color(0xFF3A3A3F) : const Color(0xFFF8F8F8);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end:   Alignment(_anim.value,     0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}
