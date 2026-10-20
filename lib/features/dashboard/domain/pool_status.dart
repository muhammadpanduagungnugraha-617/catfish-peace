import '../../../core/thresholds.dart';

/// Cerminan node RTDB `kolam_status`.
class PoolStatus {
  const PoolStatus({
    required this.isConnected,
    required this.suhu,
    required this.ph,
    required this.kekeruhan,
    required this.amonia,
    required this.lastUpdated,
  });

  final bool isConnected;
  final double suhu;
  final double ph;
  final double kekeruhan;
  final double amonia;
  final DateTime lastUpdated;

  /// ESP32 yang mati mendadak tidak sempat menulis false,
  /// jadi last_updated juga harus dicek.
  static const Duration staleAfter = Duration(seconds: 60);

  bool get isOnline =>
      isConnected && DateTime.now().difference(lastUpdated) <= staleAfter;

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

  ParamStatus statusOf(ParamKey key) =>
      Thresholds.evaluate(key, valueOf(key));

  /// Banner keseluruhan = status terburuk dari 4 parameter.
  ParamStatus get overall =>
      ParamStatus.worst(ParamKey.values.map(statusOf));
}
