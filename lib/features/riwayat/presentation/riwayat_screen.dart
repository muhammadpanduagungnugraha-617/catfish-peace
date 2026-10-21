import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../shared/error_card.dart';
import '../../../shared/offline_banner.dart';
import '../../../shared/screen_scroll.dart';
import '../../../shared/section_header.dart';
import '../../../shared/shimmer_box.dart';
import '../../dashboard/application/pool_status_provider.dart';
import '../application/history_providers.dart';
import 'widgets/alert_log_tile.dart';
import 'widgets/chart_legend.dart';
import 'widgets/sensor_chart.dart';

class RiwayatScreen extends ConsumerWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(sensorHistoryProvider);
    final logs = ref.watch(alertLogsProvider);
    // Termasuk kasus "belum ada data dari alat" (dianggap terputus).
    final offline = ref.watch(poolConnectionProvider) == PoolConnection.offline;

    return ScreenScroll(
      children: [
        if (offline) ...[
          const OfflineBanner(),
          const SizedBox(height: 20),
        ],
        const SectionHeader(
          title: 'Riwayat Sensor',
          subtitle: 'Log suhu air, keasaman, kekeruhan, dan amonia.',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: history.when(
            loading: () => const ShimmerBox(height: 300, radius: 12),
            error: (_, __) => ErrorCard(
              message: 'Riwayat sensor tidak bisa dimuat.',
              onRetry: () => ref.invalidate(sensorHistoryProvider),
            ),
            data: (points) => points.length < 2
                ? const _EmptyChart()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SensorChart(points: points),
                const SizedBox(height: 16),
                const ChartLegend(),
                const SizedBox(height: 10),
                const Text(
                  'Skala dinormalisasi 0–100% per parameter. Sentuh grafik untuk melihat nilai asli.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Log Peringatan',
          subtitle: logs.maybeWhen(
            data: (l) => l.isEmpty
                ? 'Belum ada perubahan status pada $kHistoryLimit pencatatan terakhir'
                : '${l.length} kejadian tercatat',
            orElse: () => 'Memuat log…',
          ),
        ),
        const SizedBox(height: 12),
        logs.when(
          loading: () => const Column(
            children: [
              ShimmerBox(height: 84),
              SizedBox(height: 12),
              ShimmerBox(height: 84),
            ],
          ),
          error: (_, __) => ErrorCard(
            message: 'Log peringatan tidak bisa dimuat.',
            onRetry: () => ref.invalidate(alertLogsProvider),
          ),
          data: (items) {
            if (items.isEmpty) return const _EmptyLogs();
            return Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  AlertLogTile(log: items[i]),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Belum cukup data riwayat. Alat mencatat tiap 1 menit.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  const _EmptyLogs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 36, color: AppColors.textDisabled),
          SizedBox(height: 8),
          Text(
            'Belum ada log peringatan tercatat',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
