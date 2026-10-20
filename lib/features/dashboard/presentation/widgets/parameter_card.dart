import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/breakpoints.dart';
import '../../../../core/thresholds.dart';
import '../../../../shared/icon_badge.dart';
import '../param_icons.dart';

/// Kartu satu parameter. Mobile: rata kiri. Web: rata tengah.
class ParameterCard extends StatelessWidget {
  const ParameterCard({
    super.key,
    required this.spec,
    required this.value,
    required this.status,
    required this.onTap,
  });

  final ParamSpec spec;
  final double value;
  final ParamStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final centered = Breakpoints.isWide(context);

    final icon = IconBadge(
      icon: paramIcon(spec.key),
      size: centered ? 46 : 40,
      borderColor: AppColors.iconBlueBorder,
    );

    final label = Text(
      spec.title,
      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
    );

    final valueText = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: spec.format(value),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          TextSpan(
            text: ' ${spec.unit}',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    final statusText = Text(
      status.label,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: status.color,
      ),
    );

    final Widget body = centered
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 18),
              label,
              const SizedBox(height: 4),
              valueText,
              const SizedBox(height: 14),
              statusText,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const Spacer(),
              label,
              const SizedBox(height: 4),
              valueText,
              const SizedBox(height: 10),
              statusText,
            ],
          );

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: body),
            const Positioned(
              top: 14,
              right: 14,
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
