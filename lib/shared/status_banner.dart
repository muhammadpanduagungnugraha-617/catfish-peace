import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/breakpoints.dart';
import '../core/thresholds.dart';

class _BannerStyle {
  const _BannerStyle(
    this.bg,
    this.titleColor,
    this.icon,
    this.title,
    this.subtitle,
  );

  final Color bg;
  final Color titleColor;
  final IconData icon;
  final String title;
  final String subtitle;
}

_BannerStyle _styleOf(ParamStatus status) {
  switch (status) {
    case ParamStatus.aman:
      return const _BannerStyle(
        AppColors.amanBannerBg,
        AppColors.amanBannerTitle,
        Icons.verified_user_outlined,
        'Kondisi Aman',
        'Air kolam aman, semua parameter normal',
      );
    case ParamStatus.waspada:
      return const _BannerStyle(
        AppColors.waspadaBannerBg,
        AppColors.waspadaBannerTitle,
        Icons.warning_amber_rounded,
        'Kondisi Waspada',
        'Ada parameter di luar rentang ideal. Pantau kolam dan siap kendali manual.',
      );
    case ParamStatus.bahaya:
      return const _BannerStyle(
        AppColors.bahayaBannerBg,
        AppColors.bahayaBannerTitle,
        Icons.gpp_maybe_outlined,
        'Kondisi Bahaya',
        'Ada parameter di level berbahaya. Segera periksa kolam Anda.',
      );
  }
}

/// Banner kondisi keseluruhan (status terburuk dari 4 parameter).
/// [isStale] = alat terputus, jadi data bukan yang terbaru.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.status, this.isStale = false});

  final ParamStatus status;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final style = _styleOf(status);
    final wide = Breakpoints.isWide(context);
    final subtitle = isStale
        ? 'Berdasarkan data terakhir yang diterima. Alat sedang terputus.'
        : style.subtitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(14),
        border: wide ? Border.all(color: status.color, width: 1) : null,
      ),
      child: Row(
        children: [
          Icon(style.icon, size: 24, color: style.titleColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: style.titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
