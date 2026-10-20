import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../core/thresholds.dart';
import '../features/dashboard/application/pool_status_provider.dart';

/// Tanda tangan peringatan yang sudah ditutup user. Banner muncul lagi
/// kalau kondisi berubah (parameter / tingkat berbeda).
final emergencyDismissedProvider = StateProvider<String?>((ref) => null);

/// Banner peringatan in-app saat ada parameter Waspada / Bahaya.
/// Tidak tampil kalau alat terputus (data basi) atau semua Aman.
class EmergencyBanner extends ConsumerWidget {
  const EmergencyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(poolStatusProvider).valueOrNull;
    final dismissed = ref.watch(emergencyDismissedProvider);

    Widget child = const SizedBox.shrink(key: ValueKey('none'));

    if (status != null && status.isOnline && status.overall != ParamStatus.aman) {
      final problems = ParamKey.values
          .where((k) => status.statusOf(k) != ParamStatus.aman)
          .toList();
      final signature =
          '${status.overall.name}:${problems.map((e) => e.name).join(',')}';

      if (signature != dismissed) {
        final isBahaya = status.overall == ParamStatus.bahaya;
        final detail = problems.map((k) {
          final spec = Thresholds.specOf(k);
          return '${spec.title} ${spec.format(status.valueOf(k))} ${spec.unit} '
              '(${status.statusOf(k).label})';
        }).join(' · ');

        child = Container(
          key: ValueKey(signature),
          width: double.infinity,
          color: isBahaya ? AppColors.bahaya : AppColors.waspada,
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBahaya ? 'PERINGATAN BAHAYA' : 'PERINGATAN WASPADA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tutup',
                visualDensity: VisualDensity.compact,
                onPressed: () => ref
                    .read(emergencyDismissedProvider.notifier)
                    .state = signature,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
        );
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}
