/// --- App routes ---

/// --- IMPORTS ---
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/pages/auth/email_verification.dart';
import 'package:mesclainvest/pages/auth/login.dart';
import 'package:mesclainvest/pages/auth/register.dart';
import 'package:mesclainvest/pages/dashboard/dashboard.dart';
import 'package:mesclainvest/pages/home/home.dart';


/// --- HELPERS ---

/// I wrap a stream as a [ChangeNotifier] so GoRouter can react to
/// auth state changes and re-evaluate redirects automatically.
class GoRouterRefreshStream extends ChangeNotifier {

  // stream subscription kept alive for the lifetime of the router
  late final StreamSubscription<dynamic> _sub;

  /// I subscribe to [stream] and notify GoRouter on every event.
  ///
  /// :param stream: the stream to listen to (e.g. authStateChanges)
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  /// I cancel the subscription when the notifier is disposed.
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}


/// --- GLOBALS ---

// initialize app router with reactive redirect tied to auth state changes
final router = GoRouter(
  initialLocation: '/',

  // re-evaluate redirect whenever auth state changes
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges()
  ),

  redirect: (context, state) {

    // resolve current auth state
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isEmailVerified = user?.emailVerified ?? false;

    // fully authenticated means logged in AND email verified
    final isFullyAuthenticated = isLoggedIn && isEmailVerified;

    final location = state.matchedLocation;

    // protect /dashboard: only fully authenticated users may enter
    if (location == '/dashboard' && !isFullyAuthenticated) return '/login';

    // fully authenticated user should not visit auth pages
    if (isFullyAuthenticated &&
        (location == '/login' || location == '/register')) {
      return '/dashboard';
    }

    // no redirect needed
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

    // email verification route — receives email and password via extra map
    GoRoute(
      path: '/email-verification',
      builder: (context, state) {
        // extract credentials passed from RegisterPage via extra
        final extra = state.extra as Map<String, String>? ?? {};
        final email = extra['email'] ?? '';
        final password = extra['password'] ?? '';

        return EmailVerificationPage(email: email, password: password);
      },
    ),
  ],
);
