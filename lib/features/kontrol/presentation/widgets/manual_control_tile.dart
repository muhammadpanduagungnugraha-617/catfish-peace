import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../shared/icon_badge.dart';

/// Satu baris saklar kendali manual (pompa / aerator).
/// Saat [enabled] false (Mode Otomatis nyala) tampil pudar dan tidak bisa
/// diklik, tapi status "Sedang nyala/mati" tetap terlihat.
class ManualControlTile extends StatelessWidget {
  const ManualControlTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.isOn,
    required this.statusText,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;

  /// Posisi saklar.
  final bool isOn;

  /// Teks status di bawah judul. Berasal dari status ASLI relay, bukan dari
  /// perintah yang dikirim.
  final String statusText;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryButton.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            IconBadge(
              icon: icon,
              size: 40,
              iconColor: iconColor,
              background: iconBackground,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: enabled
                          ? AppColors.textSecondary
                          : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: isOn, onChanged: enabled ? onChanged : null),
          ],
        ),
      ),
    );
  }
}
