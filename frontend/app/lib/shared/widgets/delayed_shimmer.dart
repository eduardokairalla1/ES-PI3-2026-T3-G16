import 'dart:async';
import 'package:flutter/material.dart';

/// Shows [skeleton] only after [delay] if [isLoading] is still true.
/// If loading finishes before the delay fires, [child] is shown directly
/// without the skeleton ever appearing.
class DelayedShimmer extends StatefulWidget {

  final bool isLoading;
  final Widget child;
  final Widget skeleton;
  final Duration delay;

  const DelayedShimmer({
    super.key,
    required this.isLoading,
    required this.child,
    required this.skeleton,
    this.delay = const Duration(milliseconds: 300),
  });

  @override
  State<DelayedShimmer> createState() => _DelayedShimmerState();
}

class _DelayedShimmerState extends State<DelayedShimmer> {

  bool _showSkeleton = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) _startTimer();
  }

  @override
  void didUpdateWidget(DelayedShimmer old) {
    super.didUpdateWidget(old);

    if (!old.isLoading && widget.isLoading) {
      _startTimer();
    }

    if (old.isLoading && !widget.isLoading) {
      _timer?.cancel();
      if (_showSkeleton) setState(() => _showSkeleton = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.delay, () {
      if (mounted && widget.isLoading) setState(() => _showSkeleton = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;
    if (_showSkeleton) return widget.skeleton;
    return const SizedBox.shrink();
  }
}
