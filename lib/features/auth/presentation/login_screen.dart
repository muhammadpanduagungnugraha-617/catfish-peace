import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/breakpoints.dart';
import '../../../shared/app_logo.dart';
import 'widgets/login_form.dart';
import 'widgets/login_tagline_badge.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Breakpoints.isWide(context)
        ? const _LoginWeb()
        : const _LoginMobile();
  }
}

/// Layout web: latar gradien radial, kartu putih di tengah.
class _LoginWeb extends StatelessWidget {
  const _LoginWeb();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.1,
            colors: [Color(0xFF165A7F), Color(0xFF0B3A57), Color(0xFF072A3F)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.35),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: const AppLogo(size: 92),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Catfish Peace',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryButton,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'SISTEM MONITORING & KONTROL KUALITAS AIR KOLAM',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const LoginTaglineBadge(),
                            const SizedBox(height: 20),
                            const Divider(color: Color(0xFFE8EDF2), height: 1),
                            const SizedBox(height: 20),
                            const LoginForm(
                              title: 'Masuk ke Dashboard',
                              subtitle:
                                  'Silakan masuk untuk mengakses sistem monitoring kolam',
                              style: LoginStyle.web,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Catfish Peace System v1.0.0 • Platform Monitoring Budidaya Lele',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF7FB0CC)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Layout mobile: header gradien melengkung, kartu putih menimpa header.
class _LoginMobile extends StatelessWidget {
  const _LoginMobile();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(24, topInset + 40, 24, 56),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF061D2C), Color(0xFF0B3A57)],
                      ),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(40)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const AppLogo(size: 76),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Catfish Peace',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sistem Monitoring & Kontrol Kualitas Air Kolam',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const LoginTaglineBadge(onDark: true),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryButton
                                .withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const LoginForm(
                        title: 'Selamat Datang Kembali',
                        subtitle:
                            'Masuk untuk memantau & mengontrol kolam budidaya Anda',
                        style: LoginStyle.mobile,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Catfish Peace App v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
