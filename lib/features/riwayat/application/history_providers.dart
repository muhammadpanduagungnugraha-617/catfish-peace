import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database_provider.dart';
import '../domain/alert_derivation.dart';
import '../domain/alert_log.dart';
import '../domain/sensor_point.dart';

/// Jumlah pencatatan terakhir yang dimuat. Firmware menulis tiap 1 menit,
/// jadi 120 titik = 2 jam terakhir.
const int kHistoryLimit = 120;

/// Ubah snapshot `sensor_history` menjadi daftar titik urut waktu naik.
/// Entri rusak dilewati.
List<SensorPoint> parseSensorHistory(Object? raw) {
  if (raw is! Map) return const [];
  final points = <SensorPoint>[];
  raw.forEach((key, value) {
    final p = SensorPoint.tryParse(key, value);
    if (p != null) points.add(p);
  });
  points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return points;
}

/// Stream langsung dari RTDB `sensor_history` (kunci = epoch detik).
final sensorHistoryProvider = StreamProvider<List<SensorPoint>>((ref) {
  final query = ref
      .watch(databaseProvider)
      .ref('sensor_history')
      .orderByKey()
      .limitToLast(kHistoryLimit);
  return query.onValue.map((e) => parseSensorHistory(e.snapshot.value));
});

/// Log peringatan diturunkan dari perubahan status di `sensor_history`.
final alertLogsProvider = Provider<AsyncValue<List<AlertLog>>>((ref) {
  return ref.watch(sensorHistoryProvider).whenData(deriveAlertLogs);
});
