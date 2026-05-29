// --- App routes ---

// --- IMPORTS ---
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/auth/forgot_password_page.dart';
import 'package:mesclainvest/pages/auth/setup_2fa_page.dart';
import 'package:mesclainvest/pages/auth/verify_2fa_page.dart';
import 'package:mesclainvest/pages/catalog/catalog_page.dart';
import 'package:mesclainvest/pages/auth/login_page.dart';
import 'package:mesclainvest/pages/auth/register_page.dart';
import 'package:mesclainvest/pages/auth/reset_password_page.dart';
import 'package:mesclainvest/pages/balcao/balcao_page.dart';
import 'package:mesclainvest/pages/carteira/carteira_page.dart';
import 'package:mesclainvest/pages/carteira/investimentos_page.dart';
import 'package:mesclainvest/pages/dashboard/pagina_dashboard.dart';
import 'package:mesclainvest/pages/home/home.dart';
import 'package:mesclainvest/pages/profile/profile_page.dart';
import 'package:mesclainvest/pages/profile/sub_pages/help_page.dart';
import 'package:mesclainvest/pages/profile/sub_pages/settings_page.dart';
import 'package:mesclainvest/pages/startup/startup_balcao_page.dart';
import 'package:mesclainvest/pages/startup/startup_detail_page.dart';
import 'package:mesclainvest/pages/startup/valorizacao_page.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/shared/widgets/bottom_nav.dart';
import 'package:mesclainvest/shared/widgets/light_theme_scope.dart';

/// Bridges a Stream into a Listenable so GoRouter re-evaluates redirects
/// whenever the auth state changes.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}


/// --- GLOBAIS ---

// inicializa o roteador do app
final router = GoRouter(
  initialLocation: '/',
  refreshListenable: Listenable.merge([
    _GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    AppState.instance,
  ]),
  redirect: (context, state) {
    final isLoggedIn   = FirebaseAuth.instance.currentUser != null;
    final pendingTwoFa = AppState.instance.pendingTwoFa;
    final loc          = state.matchedLocation;

    // 2FA pending: only /verify-2fa is accessible
    if (pendingTwoFa && loc != '/verify-2fa') return '/verify-2fa';

    // not logged in + protected route → login
    final protectedPaths = ['/dashboard', '/catalog', '/balcao', '/carteira', '/profile', '/startup'];
    if (!isLoggedIn && protectedPaths.any((p) => loc.startsWith(p))) return '/login';

    // logged in (no pending 2FA, not mid-registration) + auth pages → dashboard
    final isRegistering = AppState.instance.isRegistering;
    final authPaths = ['/login', '/register'];
    if (isLoggedIn && !pendingTwoFa && !isRegistering && authPaths.contains(loc)) return '/dashboard';

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LightThemeScope(child: HomePage()),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LightThemeScope(child: LoginPage()),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const LightThemeScope(child: RegisterPage()),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const LightThemeScope(child: ForgotPasswordPage()),
    ),
    GoRoute(
      path: '/verify-2fa',
      builder: (context, state) => const Verify2FAPage(),
    ),
    GoRoute(
      path: '/setup-2fa',
      builder: (context, state) => const Setup2FAPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => LightThemeScope(
        child: ResetPasswordPage(
          oobCode: state.uri.queryParameters['oobCode'] ?? '',
        ),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: SafeArea(
            child: BottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                AppState.instance.onNavigate();
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) {
                final filter = state.uri.queryParameters['filter'];
                return NoTransitionPage(
                  child: PaginaDashboard(initialFilter: filter),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/catalog',
              pageBuilder: (context, state) => const NoTransitionPage(child: CatalogPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/carteira',
              pageBuilder: (context, state) => const NoTransitionPage(child: CarteiraPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/balcao',
              pageBuilder: (context, state) => const NoTransitionPage(child: BalcaoPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/carteira/investimentos',
      builder: (context, state) => const InvestimentosPage(),
    ),
    GoRoute(
      path: '/startup/:id',
      builder: (context, state) => StartupDetailPage(
        startupId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/startup/:id/balcao',
      builder: (context, state) => StartupBalcaoPage(
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
      path: '/profile/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/profile/help',
      builder: (context, state) => const HelpPage(),
    ),
  ],
);
