import '../../../core/thresholds.dart';
import 'alert_log.dart';
import 'sensor_point.dart';

/// Membuat log peringatan dari perubahan status antar pencatatan
/// `sensor_history` (aman -> waspada/bahaya, dan kembali aman).
/// [points] harus urut waktu naik. Hasil: terbaru dulu, maksimal [max].
List<AlertLog> deriveAlertLogs(List<SensorPoint> points, {int max = 30}) {
  final logs = <AlertLog>[];
  for (final key in ParamKey.values) {
    final spec = Thresholds.specOf(key);
    ParamStatus? prev;
    for (final p in points) {
      final v = p.valueOf(key);
      final status = Thresholds.evaluate(key, v);
      final changed = status != prev;
      final interesting = prev != null || status != ParamStatus.aman;
      prev = status;
      if (!changed || !interesting) continue;

      final nilai = '${spec.format(v)} ${spec.unit}';
      final String title;
      final String description;
      switch (status) {
        case ParamStatus.bahaya:
          title = 'Bahaya: ${spec.title} · $nilai';
          description = spec.bahayaAction;
        case ParamStatus.waspada:
          title = 'Waspada: ${spec.title} · $nilai';
          description = 'Nilai mendekati batas aman, pantau terus.';
        case ParamStatus.aman:
          title = '${spec.title} Normal · $nilai';
          description = 'Kembali ke rentang aman.';
      }
      logs.add(AlertLog(
        id: '${key.name}-${p.timestamp.millisecondsSinceEpoch}',
        type: status,
        parameter: key,
        nilai: v,
        title: title,
        description: description,
        timestamp: p.timestamp,
      ));
    }
  }
  logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return logs.length > max ? logs.sublist(0, max) : logs;
}
