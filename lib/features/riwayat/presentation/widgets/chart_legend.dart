import 'package:flutter/material.dart';

import '../../../../core/thresholds.dart';
import '../chart_colors.dart';

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 28,
      runSpacing: 10,
      children: [
        for (final key in ParamKey.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 12,
                decoration: BoxDecoration(
                  color: chartColorOf(key),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(chartLabelOf(key), style: const TextStyle(fontSize: 13)),
            ],
          ),
      ],
    );
  }
}
