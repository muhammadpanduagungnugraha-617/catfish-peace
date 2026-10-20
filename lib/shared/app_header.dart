import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/breakpoints.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/dashboard/application/pool_status_provider.dart';
import 'app_logo.dart';
import 'connection_badge.dart';

/// Header gradien: logo + judul (+ subjudul di mobile) + badge koneksi + logout.
class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = Breakpoints.isWide(context);
    final status = ref.watch(poolStatusProvider).valueOrNull;

    final badge = status == null
        ? ConnectionBadgeState.connecting
        : status.isOnline
            ? ConnectionBadgeState.connected
            : ConnectionBadgeState.disconnected;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.headerStart, AppColors.headerEnd],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 40 : 16,
            vertical: wide ? 28 : 20,
          ),
          child: Row(
            children: [
              const AppLogo(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catfish Peace',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (!wide)
                      const Text(
                        'Monitoring Kualitas Air Kolam',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: kDebugMode ? () => _cycleScenario(context, ref) : null,
                child: ConnectionBadge(state: badge),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Keluar',
                iconSize: 20,
                color: Colors.white70,
                onPressed: () => _confirmLogout(context, ref),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cycleScenario(BuildContext context, WidgetRef ref) {
    final current = ref.read(dummyScenarioProvider);
    final next = DummyScenario
        .values[(current.index + 1) % DummyScenario.values.length];
    ref.read(dummyScenarioProvider.notifier).state = next;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Skenario dummy: ${next.label}')),
      );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Anda perlu masuk lagi untuk memantau kolam.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // TODO(firebase): await FirebaseAuth.instance.signOut();
      ref.read(authProvider.notifier).state = false;
      context.go('/login');
    }
  }
}
