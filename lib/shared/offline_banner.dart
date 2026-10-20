import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Banner peach saat alat IoT terputus.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.offlineBannerBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 20, color: AppColors.offlineIcon),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Alat IoT kolam tidak terhubung ke internet',
              style: TextStyle(
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
