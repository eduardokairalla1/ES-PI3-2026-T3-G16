/// --- App routes ---

/// --- IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/auth/login.dart';
import 'package:mesclainvest/pages/auth/register.dart';
import 'package:mesclainvest/pages/dashboard/dashboard.dart';
import 'package:mesclainvest/pages/home/home.dart';


/// --- GLOBALS ---

// initialize app router
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {

    // check if user is logged
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // check if user is trying to access the dashboard
    final isDashboard = state.matchedLocation == '/dashboard';

    // user is not logged and trying to access the dashboard: redirect to login
    if (!isLoggedIn && isDashboard) return '/login';

    // user is logged and trying to access login or register: redirect to
    // dashboard
    return null;

  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
  ],
);
