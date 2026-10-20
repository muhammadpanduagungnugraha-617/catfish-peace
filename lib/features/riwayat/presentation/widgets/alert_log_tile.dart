import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/thresholds.dart';
import '../../../../shared/icon_badge.dart';
import '../../domain/alert_log.dart';

class AlertLogTile extends StatelessWidget {
  const AlertLogTile({super.key, required this.log});

  final AlertLog log;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color iconColor;
    late final Color bg;
    switch (log.type) {
      case ParamStatus.bahaya:
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.bahaya;
        bg = AppColors.bahayaIconBg;
      case ParamStatus.waspada:
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.waspada;
        bg = AppColors.waspadaBannerBg;
      case ParamStatus.aman:
        icon = Icons.check_circle_outline;
        iconColor = AppColors.aman;
        bg = AppColors.amanBannerBg;
    }

    final time = DateFormat('d MMMM yyyy, HH.mm.ss', 'id_ID')
        .format(log.timestamp);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, size: 44, iconColor: iconColor, background: bg),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  log.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textDisabled,
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
