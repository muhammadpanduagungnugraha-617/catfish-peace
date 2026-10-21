import '../../../core/thresholds.dart';

/// Satu titik di node RTDB `sensor_history`.
class SensorPoint {
  const SensorPoint({
    required this.timestamp,
    required this.suhu,
    required this.ph,
    required this.kekeruhan,
    required this.amonia,
  });

  /// Parse satu entri `sensor_history/<epoch>`. Kunci = epoch detik; bila
  /// field `timestamp` ada, ia yang dipakai. Entri rusak -> null (dilewati).
  static SensorPoint? tryParse(Object? key, Object? raw) {
    if (raw is! Map) return null;
    double? num_(Object? v) =>
        (v is num && v.isFinite) ? v.toDouble() : null;
    final suhu = num_(raw['suhu']);
    final ph = num_(raw['ph']);
    final kek = num_(raw['kekeruhan']);
    final amo = num_(raw['amonia']);
    final ts = num_(raw['timestamp']) ?? num.tryParse('$key')?.toDouble();
    if (suhu == null || ph == null || kek == null || amo == null) return null;
    if (ts == null || ts <= 0) return null;
    // Toleransi milidetik (>= 1e11 detik tidak mungkin).
    final sec = ts >= 1e11 ? ts / 1000 : ts;
    return SensorPoint(
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((sec * 1000).round()),
      suhu: suhu,
      ph: ph,
      kekeruhan: kek,
      amonia: amo,
    );
  }

  final DateTime timestamp;
  final double suhu;
  final double ph;
  final double kekeruhan;
  final double amonia;

  double valueOf(ParamKey key) {
    switch (key) {
      case ParamKey.suhu:
        return suhu;
      case ParamKey.ph:
        return ph;
      case ParamKey.kekeruhan:
        return kekeruhan;
      case ParamKey.amonia:
        return amonia;
    }
  }
}
