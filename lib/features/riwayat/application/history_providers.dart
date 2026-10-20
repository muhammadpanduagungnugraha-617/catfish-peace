import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config.dart';
import '../../../core/thresholds.dart';
import '../domain/alert_log.dart';
import '../domain/sensor_point.dart';

/// Tahap UI: 24 titik per jam (dummy). Nanti dari RTDB `sensor_history`.
final sensorHistoryProvider = FutureProvider<List<SensorPoint>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  final now = DateTime.now();
  return List.generate(24, (i) {
    final amonia = i == 19
        ? 0.42
        : i == 20
            ? 0.65
            : i == 21
                ? 0.38
                : 0.14 + 0.02 * sin(i.toDouble());
    return SensorPoint(
      timestamp: now.subtract(Duration(hours: 23 - i)),
      suhu: 28.3 + 0.8 * sin(i / 3.0),
      ph: 7.2 + 0.25 * cos(i / 4.0),
      kekeruhan: 8.0 + 4.0 * sin(i / 2.5),
      amonia: amonia,
    );
  });
});

/// Tahap UI: 2 log dummy. Nanti dari Firestore `alert_logs` (urut terbaru).
final alertLogsProvider = FutureProvider<List<AlertLog>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  if (kDummyEmptyLogs) return const [];
  final now = DateTime.now();
  return [
    AlertLog(
      id: 'a2',
      type: ParamStatus.bahaya,
      parameter: ParamKey.amonia,
      nilai: 0.65,
      title: 'Bahaya: Amonia Tinggi · 0.65 PPM',
      description: 'Aktifkan pompa & aerator untuk menurunkan amonia.',
      timestamp: now.subtract(const Duration(hours: 3, minutes: 30)),
    ),
    AlertLog(
      id: 'a1',
      type: ParamStatus.aman,
      parameter: ParamKey.amonia,
      nilai: 0.15,
      title: 'Amonia Normal · 0.15 PPM',
      description: 'Kadar amonia kembali ke rentang aman.',
      timestamp: now.subtract(const Duration(hours: 3)),
    ),
  ];
});
