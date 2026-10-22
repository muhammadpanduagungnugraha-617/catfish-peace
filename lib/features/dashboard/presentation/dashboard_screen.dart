import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
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

    if (async.hasError && !async.hasValue) {
      return ScreenScroll(
        children: [
          ErrorCard(
            message: 'Data kolam tidak bisa dimuat. Periksa koneksi atau izin akses.',
            onRetry: () => ref.invalidate(poolStatusProvider),
          ),
        ],
      );
    }

    // Node kosong: alat belum pernah mengirim data. Jangan tampilkan angka
    // palsu sebagai pembacaan sensor.
    if (async.hasValue && status == null) {
      return const ScreenScroll(
        children: [
          OfflineBanner(),
          SizedBox(height: 24),
          _NoDataCard(),
        ],
      );
    }

    final offline = status != null && !status.isOnline;

    // Alat online tetapi sensor air tidak terbaca: jangan tampilkan angka.
    if (status != null && !status.sensorOk) {
      return ScreenScroll(
        children: [
          if (offline) ...[
            const OfflineBanner(),
            const SizedBox(height: 12),
          ],
          const _SensorErrorCard(),
        ],
      );
    }

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

class _SensorErrorCard extends StatelessWidget {
  const _SensorErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.build_circle_outlined,
              size: 40, color: AppColors.bahaya),
          SizedBox(height: 12),
          Text(
            'Sensor bermasalah',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Alat terhubung, tetapi pembacaan sensor air tidak wajar '
            '(kabel lepas atau rusak). Periksa sensor di kolam. '
            'Pompa otomatis ditahan sampai sensor pulih.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NoDataCard extends StatelessWidget {
  const _NoDataCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.sensors_off_outlined,
              size: 40, color: AppColors.textDisabled),
          SizedBox(height: 12),
          Text(
            'Belum ada data dari alat',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Data akan muncul setelah alat IoT mengirim pembacaan pertama.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
