/// Eduardo Kairalla - 24024241

/// Global bottom navigation bar shared across main pages.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


// --- WIDGET ---

class BottomNav extends StatelessWidget {

  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
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
          _item(context, 0, Icons.home_outlined,         Icons.home,          'Home',      '/dashboard'),
          _item(context, 1, Icons.rocket_launch_outlined, Icons.rocket_launch,  'Startups',  '/catalog'),
          _item(context, 2, Icons.storefront_outlined,   Icons.storefront,      'Balcão',    null),
          _item(context, 3, Icons.person_outline,         Icons.person,          'Perfil',    '/profile'),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    IconData iconOutlined,
    IconData iconFilled,
    String label,
    String? route,
  ) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isActive) return;
          if (route == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Em breve!'),
                backgroundColor: Colors.black,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          context.go(route);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? iconFilled : iconOutlined,
              size: 24,
              color: isActive ? Colors.black : const Color(0xFFAAAAAA),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.black : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
