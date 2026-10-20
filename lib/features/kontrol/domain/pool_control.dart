/// Cerminan node RTDB `kolam_control`.
class PoolControl {
  const PoolControl({
    this.modeOtomatis = false,
    this.pompaBuangAir = true,
    this.pompaIsiAir = false,
    this.pompaSirkulasi = false,
    this.aerator = false,
  });

  final bool modeOtomatis;
  final bool pompaBuangAir;
  final bool pompaIsiAir;
  final bool pompaSirkulasi; // belum ada di UI (lihat pertanyaan terbuka)
  final bool aerator;

  PoolControl copyWith({
    bool? modeOtomatis,
    bool? pompaBuangAir,
    bool? pompaIsiAir,
    bool? pompaSirkulasi,
    bool? aerator,
  }) {
    return PoolControl(
      modeOtomatis: modeOtomatis ?? this.modeOtomatis,
      pompaBuangAir: pompaBuangAir ?? this.pompaBuangAir,
      pompaIsiAir: pompaIsiAir ?? this.pompaIsiAir,
      pompaSirkulasi: pompaSirkulasi ?? this.pompaSirkulasi,
      aerator: aerator ?? this.aerator,
    );
  }
}
