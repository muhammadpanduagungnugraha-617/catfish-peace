import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

/// Pill tagline "Menuju Budidaya Tanpa Konflik".
/// [onDark] = versi mobile (di atas header gelap), tanpa ikon.
class LoginTaglineBadge extends StatelessWidget {
  const LoginTaglineBadge({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.accentBadgeBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.2)
              : AppColors.accentBadgeBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!onDark) ...[
            const Icon(Icons.check_circle,
                size: 14, color: Color(0xFFD4881E)),
            const SizedBox(width: 6),
          ],
          Text(
            'Menuju Budidaya Tanpa Konflik',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: onDark ? AppColors.accent : AppColors.accentBadgeText,
            ),
          ),
        ],
      ),
    );
  }
}
