/// --- App routes ---

/// --- IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/auth/forgot_password_page.dart';
import 'package:mesclainvest/pages/catalog/catalog_page.dart';
import 'package:mesclainvest/pages/auth/login_page.dart';
import 'package:mesclainvest/pages/auth/register_page.dart';
import 'package:mesclainvest/pages/auth/reset_password_page.dart';
import 'package:mesclainvest/pages/dashboard/pagina_dashboard.dart';
import 'package:mesclainvest/pages/home/home.dart';
import 'package:mesclainvest/pages/profile/profile_page.dart';
import 'package:mesclainvest/pages/profile/sub_pages/help_page.dart';
import 'package:mesclainvest/pages/profile/sub_pages/settings_page.dart';
import 'package:mesclainvest/pages/startup/startup_detail_page.dart';


/// --- GLOBAIS ---

// inicializa o roteador do app
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {

    // verifica se o usuário está logado
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // verifica se o usuário está tentando acessar uma rota protegida
    final protectedPaths = ['/dashboard', '/catalog', '/profile', '/startup'];
    final isProtected = protectedPaths.any((p) => state.matchedLocation.startsWith(p));

    // usuário não está logado e tentando acessar rota protegida: redireciona para login
    if (!isLoggedIn && isProtected) return '/login';

    // usuário está logado e tentando acessar login ou registro: redireciona para
    // o dashboard
    final authPaths = ['/login', '/register'];
    if (isLoggedIn && authPaths.contains(state.matchedLocation)) return '/dashboard';

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
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => ResetPasswordPage(
        oobCode: state.uri.queryParameters['oobCode'] ?? '',
      ),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const PaginaDashboard(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const CatalogPage(),
    ),
    GoRoute(
      path: '/startup/:id',
      builder: (context, state) => StartupDetailPage(
        startupId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/profile/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/profile/help',
      builder: (context, state) => const HelpPage(),
    ),
  ],
);
