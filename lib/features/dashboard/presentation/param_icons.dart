import 'package:flutter/material.dart';

import '../../../core/thresholds.dart';

/// Satu tempat untuk ikon parameter (versi mobile dipakai di semua platform).
IconData paramIcon(ParamKey key) {
  switch (key) {
    case ParamKey.suhu:
      return Icons.thermostat_outlined;
    case ParamKey.ph:
      return Icons.science_outlined;
    case ParamKey.kekeruhan:
      return Icons.water_drop_outlined;
    case ParamKey.amonia:
      return Icons.bubble_chart_outlined;
  }
}
