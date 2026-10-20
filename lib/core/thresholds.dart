import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Status satu parameter. Urutan enum = tingkat keparahan (aman < bahaya).
enum ParamStatus {
  aman('AMAN', AppColors.aman),
  waspada('WASPADA', AppColors.waspada),
  bahaya('BAHAYA', AppColors.bahaya);

  const ParamStatus(this.label, this.color);

  final String label;
  final Color color;

  int get severity => index;

  /// Status terburuk dari kumpulan status (dipakai untuk banner keseluruhan).
  static ParamStatus worst(Iterable<ParamStatus> statuses) =>
      statuses.reduce((a, b) => a.severity >= b.severity ? a : b);
}

enum ParamKey { suhu, ph, kekeruhan, amonia }

/// Metadata tampilan + teks rentang satu parameter.
class ParamSpec {
  const ParamSpec({
    required this.key,
    required this.title,
    required this.unit,
    required this.decimals,
    required this.amanRange,
    required this.waspadaRange,
    required this.bahayaRange,
    required this.bahayaAction,
  });

  final ParamKey key;
  final String title;
  final String unit;
  final int decimals;
  final String amanRange;
  final String waspadaRange;
  final String bahayaRange;
  final String bahayaAction;

  String format(double v) => v.toStringAsFixed(decimals);
}

/// Satu-satunya sumber threshold (Tabel 2.3 proposal). Dipakai untuk
/// menghitung status DAN untuk dialog "rentang ideal".
class Thresholds {
  Thresholds._();

  static const Map<ParamKey, ParamSpec> specs = {
    ParamKey.suhu: ParamSpec(
      key: ParamKey.suhu,
      title: 'Suhu Air',
      unit: '°C',
      decimals: 1,
      amanRange: '25.0 – 30.0 °C',
      waspadaRange: '24.0 – <25.0 °C atau >30.0 – 31.0 °C',
      bahayaRange: '< 24.0 °C atau > 31.0 °C',
      bahayaAction:
          'Notifikasi dikirim. Cek kondisi fisik kolam / peneduh (tanpa ganti air).',
    ),
    ParamKey.ph: ParamSpec(
      key: ParamKey.ph,
      title: 'Keasaman (pH)',
      unit: 'pH',
      decimals: 1,
      amanRange: '6.5 – 8.5',
      waspadaRange: '6.0 – <6.5 atau >8.5 – 9.0',
      bahayaRange: '< 6.0 atau > 9.0',
      bahayaAction: 'Notifikasi dikirim dan pompa sirkulasi air menyala otomatis.',
    ),
    ParamKey.kekeruhan: ParamSpec(
      key: ParamKey.kekeruhan,
      title: 'Kekeruhan',
      unit: 'NTU',
      decimals: 1,
      amanRange: '0 – 50 NTU',
      waspadaRange: '>50 – 60 NTU',
      bahayaRange: '> 60 NTU',
      bahayaAction:
          'Notifikasi dikirim dan pompa penggantian air menyala otomatis.',
    ),
    ParamKey.amonia: ParamSpec(
      key: ParamKey.amonia,
      title: 'Amonia',
      unit: 'PPM',
      decimals: 2,
      amanRange: '≤ 0.50 PPM',
      waspadaRange: '>0.50 – <0.60 PPM',
      bahayaRange: '≥ 0.60 PPM',
      bahayaAction:
          'Emergency Alert dikirim, aerator dan pompa penggantian air menyala otomatis.',
    ),
  };

  static ParamSpec specOf(ParamKey key) => specs[key]!;

  /// Batas dibuat kontinu agar tidak ada celah (mis. 50.5 NTU).
  static ParamStatus evaluate(ParamKey key, double v) {
    switch (key) {
      case ParamKey.suhu:
        if (v < 24.0 || v > 31.0) return ParamStatus.bahaya;
        if (v < 25.0 || v > 30.0) return ParamStatus.waspada;
        return ParamStatus.aman;
      case ParamKey.ph:
        if (v < 6.0 || v > 9.0) return ParamStatus.bahaya;
        if (v < 6.5 || v > 8.5) return ParamStatus.waspada;
        return ParamStatus.aman;
      case ParamKey.kekeruhan:
        if (v > 60.0) return ParamStatus.bahaya;
        if (v > 50.0) return ParamStatus.waspada;
        return ParamStatus.aman;
      case ParamKey.amonia:
        if (v >= 0.60) return ParamStatus.bahaya;
        if (v > 0.50) return ParamStatus.waspada;
        return ParamStatus.aman;
    }
  }
}
