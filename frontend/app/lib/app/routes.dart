/// --- App routes ---

/// --- IMPORTS ---
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/home/home.dart';


/// --- GLOBALS ---

// initialize app router
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
