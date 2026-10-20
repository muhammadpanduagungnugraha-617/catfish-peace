import 'package:flutter/material.dart';

import '../../../../core/breakpoints.dart';
import '../../../../core/thresholds.dart';
import '../../../../shared/shimmer_box.dart';
import '../../domain/pool_status.dart';
import 'ideal_range_sheet.dart';
import 'parameter_card.dart';

/// Grid 4 kartu: 2x2 di mobile, 4 kolom di web.
/// [status] null = loading (skeleton shimmer).
class ParameterGrid extends StatelessWidget {
  const ParameterGrid({super.key, required this.status});

  final PoolStatus? status;

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isWide(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: wide ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: wide ? 1.5 : 0.94,
      children: [
        for (final key in ParamKey.values)
          if (status == null)
            const ShimmerBox(radius: 24)
          else
            ParameterCard(
              spec: Thresholds.specOf(key),
              value: status!.valueOf(key),
              status: status!.statusOf(key),
              onTap: () => showIdealRange(
                context,
                paramKey: key,
                value: status!.valueOf(key),
              ),
            ),
      ],
    );
  }
}
