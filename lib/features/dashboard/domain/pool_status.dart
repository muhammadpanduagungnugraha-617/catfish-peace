import '../../../core/app_config.dart';
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
    this.sensorOk = true,
    this.serverOffset = Duration.zero,
  });

  final bool isConnected;
  final double suhu;
  final double ph;
  final double kekeruhan;
  final double amonia;

  /// false = alat hidup tetapi sensor air tidak terbaca wajar (lepas/korslet).
  /// Angka di atas tidak boleh ditampilkan sebagai pembacaan sah.
  final bool sensorOk;

  /// Waktu pembaruan terakhir dari ESP32 (epoch detik, jam server/NTP).
  final DateTime lastUpdated;

  /// Selisih jam server terhadap jam perangkat ini
  /// (RTDB `.info/serverTimeOffset`). Dipakai agar jam HP yang meleset
  /// tidak membuat alat tampak "Terputus".
  final Duration serverOffset;

  /// ESP32 yang mati mendadak tidak sempat menulis false,
  /// jadi last_updated juga harus dicek.
  static const Duration staleAfter = kStaleAfter;

  /// `last_updated` yang terlalu jauh di masa depan berarti jam ESP32 salah
  /// (NTP belum sinkron). Dianggap terputus supaya kesalahannya kelihatan,
  /// bukan tersamarkan sebagai "Terhubung" selamanya.
  static const Duration _futureTolerance = Duration(seconds: 10);

  DateTime get serverNow => DateTime.now().add(serverOffset);

  bool get isOnline {
    if (!isConnected) return false;
    final age = serverNow.difference(lastUpdated);
    return age >= -_futureTolerance && age <= staleAfter;
  }

  PoolStatus withServerOffset(Duration offset) => PoolStatus(
        isConnected: isConnected,
        suhu: suhu,
        ph: ph,
        kekeruhan: kekeruhan,
        amonia: amonia,
        lastUpdated: lastUpdated,
        sensorOk: sensorOk,
        serverOffset: offset,
      );

  /// Parsing aman dari nilai mentah RTDB. Mengembalikan null bila node kosong
  /// atau datanya tidak lengkap/tidak valid, supaya angka palsu tidak pernah
  /// tampil sebagai pembacaan sensor.
  static PoolStatus? tryParse(
    Object? raw, {
    Duration serverOffset = Duration.zero,
  }) {
    if (raw is! Map) return null;

    double? number(String key) {
      final v = raw[key];
      return (v is num && v.isFinite) ? v.toDouble() : null;
    }

    final suhu = number('suhu');
    final ph = number('ph');
    final kekeruhan = number('kekeruhan');
    final amonia = number('amonia');
    final ts = raw['last_updated'];
    if (suhu == null ||
        ph == null ||
        kekeruhan == null ||
        amonia == null ||
        ts is! num ||
        !ts.isFinite) {
      return null;
    }

    return PoolStatus(
      // Hilang = anggap terhubung dan andalkan last_updated.
      // Hanya `false` eksplisit (mis. dari onDisconnect) yang memutus.
      isConnected: raw['is_connected'] != false,
      suhu: suhu,
      ph: ph,
      kekeruhan: kekeruhan,
      amonia: amonia,
      lastUpdated: _fromEpoch(ts),
      sensorOk: raw['sensor_ok'] != false,
      serverOffset: serverOffset,
    );
  }

  /// Kontrak: epoch DETIK. Nilai sebesar milidetik tetap dibaca benar
  /// supaya salah satuan di firmware tidak diam-diam memutus status.
  static DateTime _fromEpoch(num v) {
    final ms = v.abs() >= 100000000000 ? v.toInt() : (v * 1000).round();
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

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
