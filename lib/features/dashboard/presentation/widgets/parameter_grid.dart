import 'dart:math' as math;

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

    // Tinggi kartu ditentukan oleh isinya, bukan oleh lebar layar. Dulu
    // memakai childAspectRatio, sehingga kartu memendek saat layar menyempit
    // padahal tinggi isinya tetap -> "BOTTOM OVERFLOWED". Nilai dasar di bawah
    // sedikit di atas tinggi isi (wide ±188 px, mobile ±153 px) dan dikalikan
    // skala font sistem supaya tetap muat saat teks diperbesar.
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final cardHeight = (wide ? 200.0 : 172.0) * math.max(1.0, textScale);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: cardHeight,
      ),
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
