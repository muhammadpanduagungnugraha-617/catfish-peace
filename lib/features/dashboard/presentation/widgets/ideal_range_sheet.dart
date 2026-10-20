import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/breakpoints.dart';
import '../../../../core/thresholds.dart';
import '../../../../shared/icon_badge.dart';
import '../param_icons.dart';

/// Tampilkan rentang ideal parameter: dialog di web, bottom sheet di mobile.
void showIdealRange(
  BuildContext context, {
  required ParamKey paramKey,
  required double value,
}) {
  if (Breakpoints.isWide(context)) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: IdealRangeContent(paramKey: paramKey, value: value),
          ),
        ),
      ),
    );
    return;
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            IdealRangeContent(paramKey: paramKey, value: value),
          ],
        ),
      ),
    ),
  );
}

class IdealRangeContent extends StatelessWidget {
  const IdealRangeContent({
    super.key,
    required this.paramKey,
    required this.value,
  });

  final ParamKey paramKey;
  final double value;

  @override
  Widget build(BuildContext context) {
    final spec = Thresholds.specOf(paramKey);
    final status = Thresholds.evaluate(paramKey, value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconBadge(
              icon: paramIcon(paramKey),
              size: 44,
              borderColor: AppColors.iconBlueBorder,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rentang Ideal',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    spec.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                'Nilai saat ini',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${spec.format(value)} ${spec.unit}  •  ${status.label}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: status.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _RangeRow(status: ParamStatus.aman, range: spec.amanRange),
        const SizedBox(height: 10),
        _RangeRow(status: ParamStatus.waspada, range: spec.waspadaRange),
        const SizedBox(height: 10),
        _RangeRow(status: ParamStatus.bahaya, range: spec.bahayaRange),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saat Bahaya: ${spec.bahayaAction}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RangeRow extends StatelessWidget {
  const _RangeRow({required this.status, required this.range});

  final ParamStatus status;
  final String range;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 84,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: status.color,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(range, style: const TextStyle(fontSize: 13.5)),
          ),
        ),
      ],
    );
  }
}
