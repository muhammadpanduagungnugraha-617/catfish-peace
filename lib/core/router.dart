import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/kontrol/presentation/kontrol_screen.dart';
import '../features/riwayat/presentation/riwayat_screen.dart';
import '../shared/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.listen(splashGateProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final gate = ref.read(splashGateProvider);
      final loc = state.matchedLocation;

      // Sesi belum terbaca (atau jeda splash belum selesai): tahan di splash.
      final resolving = (auth.isLoading && !auth.hasValue) || gate.isLoading;
      if (resolving) return loc == '/splash' ? null : '/splash';

      // Error membaca sesi diperlakukan sebagai belum login.
      final loggedIn = auth.valueOrNull != null;
      if (loggedIn) {
        return (loc == '/splash' || loc == '/login') ? '/dashboard' : null;
      }
      return loc == '/login' ? null : '/login';
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/kontrol',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: KontrolScreen()),
          ),
          GoRoute(
            path: '/riwayat',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: RiwayatScreen()),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
