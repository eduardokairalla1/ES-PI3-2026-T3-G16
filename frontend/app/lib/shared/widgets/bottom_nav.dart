/// Eduardo Kairalla - 24024241

/// Global bottom navigation bar shared across main pages.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';


class BottomNav extends StatelessWidget {

  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNav({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(index: 0, current: currentIndex, iconOutlined: Icons.home_outlined,          iconFilled: Icons.home,           label: 'Home',     route: '/dashboard', onTap: onTap),
          _NavItem(index: 1, current: currentIndex, iconOutlined: Icons.rocket_launch_outlined, iconFilled: Icons.rocket_launch,  label: 'Startups', route: '/catalog',   onTap: onTap),
          _NavItem(index: 2, current: currentIndex, iconOutlined: Icons.wallet_outlined,        iconFilled: Icons.wallet,         label: 'Carteira', route: '/carteira',  onTap: onTap),
          _NavItem(index: 3, current: currentIndex, iconOutlined: Icons.storefront_outlined,    iconFilled: Icons.storefront,     label: 'Balcão',   route: '/balcao',    onTap: onTap),
          _NavItem(index: 4, current: currentIndex, iconOutlined: Icons.person_outline,         iconFilled: Icons.person,         label: 'Perfil',   route: '/profile',   onTap: onTap),
        ],
      ),
    );
  }
}


class _NavItem extends StatefulWidget {

  final int index;
  final int current;
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  final String route;
  final ValueChanged<int>? onTap;

  const _NavItem({
    required this.index,
    required this.current,
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    required this.route,
    this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {

  double _scale = 1.0;

  bool get _isActive => widget.index == widget.current;

  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.78);

  void _onTapUp(TapUpDetails _) => setState(() => _scale = 1.0);

  void _onTapCancel() => setState(() => _scale = 1.0);

  void _onTap(BuildContext context) {
    if (_isActive) return;
    if (widget.onTap != null) {
      widget.onTap!(widget.index);
    } else {
      context.go(widget.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.textPrimary(context);
    final inactiveColor = AppColors.textMuted(context);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () => _onTap(context),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isActive ? widget.iconFilled : widget.iconOutlined,
                size: 24,
                color: _isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
