import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import 'app_bottom_nav.dart';
import 'app_header.dart';
import 'emergency_banner.dart';

const _tabPaths = ['/dashboard', '/kontrol', '/riwayat'];

/// Kerangka screen utama: header, banner peringatan, isi, bottom nav.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  int get _index {
    if (location.startsWith('/kontrol')) return 1;
    if (location.startsWith('/riwayat')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          const EmergencyBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => context.go(_tabPaths[i]),
      ),
    );
  }
}
