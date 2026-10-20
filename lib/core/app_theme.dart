import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryButton,
        primary: AppColors.primaryButton,
        surface: AppColors.background,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          final on = states.contains(WidgetState.selected);
          final disabled = states.contains(WidgetState.disabled);
          if (on) {
            return disabled
                ? AppColors.accent.withValues(alpha: 0.65)
                : AppColors.white;
          }
          return const Color(0xFFA9A39B);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          final on = states.contains(WidgetState.selected);
          final disabled = states.contains(WidgetState.disabled);
          if (on) {
            return disabled
                ? AppColors.accent.withValues(alpha: 0.30)
                : AppColors.accent;
          }
          return const Color(0xFFE3E3E3);
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryButton,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
