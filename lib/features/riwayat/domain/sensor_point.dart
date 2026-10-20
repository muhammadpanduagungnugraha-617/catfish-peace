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
