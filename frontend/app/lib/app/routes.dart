/// --- App routes ---

/// --- IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/auth/forgot_password_page.dart';
import 'package:mesclainvest/pages/catalog/catalog_page.dart';
import 'package:mesclainvest/pages/auth/login_page.dart';
import 'package:mesclainvest/pages/auth/register_page.dart';
import 'package:mesclainvest/pages/auth/reset_password_page.dart';
import 'package:mesclainvest/pages/balcao/balcao_page.dart';
import 'package:mesclainvest/pages/dashboard/pagina_dashboard.dart';
import 'package:mesclainvest/pages/home/home.dart';
import 'package:mesclainvest/pages/profile/profile_page.dart';
import 'package:mesclainvest/pages/profile/sub_pages/help_page.dart';
import 'package:mesclainvest/pages/profile/sub_pages/settings_page.dart';
import 'package:mesclainvest/pages/startup/startup_detail_page.dart';
import 'package:mesclainvest/pages/startup/valorizacao_page.dart';


/// --- GLOBAIS ---

// inicializa o roteador do app
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {

    // verifica se o usuário está logado
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // verifica se o usuário está tentando acessar uma rota protegida
    final protectedPaths = ['/dashboard', '/catalog', '/balcao', '/profile'];
    final isProtected = protectedPaths.any((p) => state.matchedLocation.startsWith(p));

    // usuário não está logado e tentando acessar rota protegida: redireciona para login
    if (!isLoggedIn && isProtected) return '/login';

    // usuário está logado e tentando acessar login ou registro: redireciona para
    // o dashboard
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
      pageBuilder: (context, state) => const NoTransitionPage(child: PaginaDashboard()),
    ),
    GoRoute(
      path: '/catalog',
      pageBuilder: (context, state) => const NoTransitionPage(child: CatalogPage()),
    ),
    GoRoute(
      path: '/balcao',
      pageBuilder: (context, state) => const NoTransitionPage(child: BalcaoPage()),
    ),
    GoRoute(
      path: '/startup/:id',
      builder: (context, state) => StartupDetailPage(
        startupId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/startup/:id/valorizacao',
      builder: (context, state) => ValorizacaoPage(
        startupId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
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
