import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/thresholds.dart';

Color chartColorOf(ParamKey key) {
  switch (key) {
    case ParamKey.suhu:
      return AppColors.chartSuhu;
    case ParamKey.ph:
      return AppColors.chartPh;
    case ParamKey.kekeruhan:
      return AppColors.chartKekeruhan;
    case ParamKey.amonia:
      return AppColors.chartAmonia;
  }
}

/// Label legend (huruf kecil, sesuai desain).
String chartLabelOf(ParamKey key) {
  switch (key) {
    case ParamKey.suhu:
      return 'suhu air';
    case ParamKey.ph:
      return 'keasaman';
    case ParamKey.kekeruhan:
      return 'kekeruhan';
    case ParamKey.amonia:
      return 'amonia';
  }
}
