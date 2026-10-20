import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Banner peach saat alat IoT terputus. [message] bisa diganti untuk kasus
/// lain yang tampilannya sama (mis. aplikasi sendiri terputus dari server).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.message = 'Alat IoT kolam tidak terhubung ke internet',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.offlineBannerBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 20, color: AppColors.offlineIcon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
