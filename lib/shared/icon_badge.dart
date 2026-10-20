import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Kotak ikon bersudut membulat (kartu parameter, kontrol, log).
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconColor = AppColors.iconBlue,
    this.background = AppColors.iconBlueBg,
    this.borderColor,
    this.radius = 12,
  });

  final IconData icon;
  final double size;
  final Color iconColor;
  final Color background;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1),
      ),
      child: Icon(icon, size: size * 0.5, color: iconColor),
    );
  }
}
