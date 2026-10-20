/// Aktuator yang bisa dikendalikan manual. `dbKey` = nama field di RTDB.
enum Actuator {
  pompaBuangAir('pompa_buang_air'),
  pompaIsiAir('pompa_isi_air'),
  pompaProbiotik('pompa_probiotik'),
  aerator('aerator');

  const Actuator(this.dbKey);
  final String dbKey;
}

/// Cerminan node RTDB `kolam_control` = PERINTAH dari app ke ESP32.
/// Bukan status asli relay (itu ada di [RelayState]).
class PoolControl {
  const PoolControl({
    this.modeOtomatis = true,
    this.pompaBuangAir = false,
    this.pompaIsiAir = false,
    this.pompaProbiotik = false,
    this.aerator = false,
  });

  final bool modeOtomatis;
  final bool pompaBuangAir;
  final bool pompaIsiAir;
  final bool pompaProbiotik;
  final bool aerator;

  bool valueOf(Actuator a) {
    switch (a) {
      case Actuator.pompaBuangAir:
        return pompaBuangAir;
      case Actuator.pompaIsiAir:
        return pompaIsiAir;
      case Actuator.pompaProbiotik:
        return pompaProbiotik;
      case Actuator.aerator:
        return aerator;
    }
  }

  /// Node kosong / field hilang:
  /// - mode_otomatis hilang = otomatis (aman untuk ikan, ESP32 memakai
  ///   aturan yang sama; lihat docs/data-contract.md).
  /// - perintah aktuator hilang = mati.
  static PoolControl fromRaw(Object? raw) {
    if (raw is! Map) return const PoolControl();
    return PoolControl(
      modeOtomatis: raw['mode_otomatis'] != false,
      pompaBuangAir: raw[Actuator.pompaBuangAir.dbKey] == true,
      pompaIsiAir: raw[Actuator.pompaIsiAir.dbKey] == true,
      pompaProbiotik: raw[Actuator.pompaProbiotik.dbKey] == true,
      aerator: raw[Actuator.aerator.dbKey] == true,
    );
  }
}

/// Cerminan node RTDB `kolam_relay` = STATUS ASLI relay yang dilaporkan ESP32.
/// UI menampilkan "Sedang nyala/mati" dari sini, bukan dari perintah.
class RelayState {
  const RelayState({
    required this.pompaBuangAir,
    required this.pompaIsiAir,
    required this.pompaProbiotik,
    required this.aerator,
  });

  final bool pompaBuangAir;
  final bool pompaIsiAir;
  final bool pompaProbiotik;
  final bool aerator;

  bool valueOf(Actuator a) {
    switch (a) {
      case Actuator.pompaBuangAir:
        return pompaBuangAir;
      case Actuator.pompaIsiAir:
        return pompaIsiAir;
      case Actuator.pompaProbiotik:
        return pompaProbiotik;
      case Actuator.aerator:
        return aerator;
    }
  }

  /// null = ESP32 belum melaporkan status relay.
  static RelayState? tryParse(Object? raw) {
    if (raw is! Map) return null;
    return RelayState(
      pompaBuangAir: raw[Actuator.pompaBuangAir.dbKey] == true,
      pompaIsiAir: raw[Actuator.pompaIsiAir.dbKey] == true,
      pompaProbiotik: raw[Actuator.pompaProbiotik.dbKey] == true,
      aerator: raw[Actuator.aerator.dbKey] == true,
    );
  }
}
