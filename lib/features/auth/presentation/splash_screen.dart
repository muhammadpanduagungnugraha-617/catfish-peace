import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../shared/app_logo.dart';
import '../application/auth_provider.dart';

/// Cek sesi lalu arahkan: sudah login -> Dashboard, belum -> Login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    // TODO(firebase): cek FirebaseAuth.instance.currentUser
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final loggedIn = ref.read(authProvider);
    context.go(loggedIn ? '/dashboard' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.headerStart, AppColors.headerEnd],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 120),
              SizedBox(height: 20),
              Text(
                'Catfish Peace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
