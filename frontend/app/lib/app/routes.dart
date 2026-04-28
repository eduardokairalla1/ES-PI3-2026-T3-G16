/// --- App routes ---

/// --- IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/auth/forgot_password.dart';
import 'package:mesclainvest/pages/auth/login.dart';
import 'package:mesclainvest/pages/auth/register.dart';
import 'package:mesclainvest/pages/dashboard/pagina_dashboard.dart';
import 'package:mesclainvest/pages/home/home.dart';
import 'package:mesclainvest/pages/portfolio/pagina_portfolio.dart';


/// --- GLOBAIS ---

// inicializa o roteador do app
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {

    // verifica se o usuário está logado
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // verifica se o usuário está tentando acessar áreas restritas
    final isRestricted = state.matchedLocation == '/dashboard' || 
                         state.matchedLocation == '/portfolio';

    // usuário não está logado e tentando acessar área restrita: redireciona para login
    if (!isLoggedIn && isRestricted) return '/login';

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
      path: '/dashboard',
      builder: (context, state) => const PaginaDashboard(),
    ),
    GoRoute(
      path: '/portfolio',
      builder: (context, state) => const PaginaPortfolio(),
    ),
  ],
);
