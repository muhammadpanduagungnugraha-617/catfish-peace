import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/error_card.dart';
import '../../../shared/offline_banner.dart';
import '../../../shared/screen_scroll.dart';
import '../../../shared/section_header.dart';
import '../../../shared/shimmer_box.dart';
import '../../../shared/status_banner.dart';
import '../application/pool_status_provider.dart';
import 'widgets/parameter_grid.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(poolStatusProvider);
    final status = async.valueOrNull;

    if (status == null && async.hasError) {
      return ScreenScroll(
        children: [
          ErrorCard(
            message: 'Data kolam tidak bisa dimuat. Periksa koneksi atau izin akses.',
            onRetry: () => ref.invalidate(poolStatusProvider),
          ),
        ],
      );
    }

    final offline = status != null && !status.isOnline;

    return ScreenScroll(
      children: [
        if (status == null)
          const ShimmerBox(height: 72, radius: 14)
        else
          StatusBanner(status: status.overall, isStale: offline),
        if (offline) ...[
          const SizedBox(height: 12),
          const OfflineBanner(),
        ],
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Parameter Air',
          subtitle: 'Ketuk kartu untuk melihat rentang ideal',
        ),
        const SizedBox(height: 16),
        ParameterGrid(status: status),
      ],
    );
  }
}
