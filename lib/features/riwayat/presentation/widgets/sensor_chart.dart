import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/breakpoints.dart';
import '../../../../core/thresholds.dart';
import '../../domain/sensor_point.dart';
import '../chart_colors.dart';

/// Grafik tren 4 parameter dalam satu sumbu.
/// Karena satuannya berbeda (°C, pH, NTU, PPM), tiap parameter dinormalisasi
/// ke 0-100% dari rentang tampilnya. Sentuh grafik untuk melihat nilai asli.
class SensorChart extends StatelessWidget {
  const SensorChart({super.key, required this.points});

  final List<SensorPoint> points;

  static const Map<ParamKey, (double, double)> _displayRange = {
    ParamKey.suhu: (20.0, 35.0),
    ParamKey.ph: (5.0, 10.0),
    ParamKey.kekeruhan: (0.0, 80.0),
    ParamKey.amonia: (0.0, 1.0),
  };

  double _normalize(ParamKey key, double v) {
    final (min, max) = _displayRange[key]!;
    return ((v - min) / (max - min) * 100).clamp(0.0, 100.0).toDouble();
  }

  LineChartBarData _line(ParamKey key) {
    final color = chartColorOf(key);
    return LineChartBarData(
      spots: [
        for (var i = 0; i < points.length; i++)
          FlSpot(i.toDouble(), _normalize(key, points[i].valueOf(key))),
      ],
      isCurved: true,
      curveSmoothness: 0.2,
      preventCurveOverShooting: true,
      barWidth: 2.5,
      color: color,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: key == ParamKey.amonia,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isWide(context);
    final timeFmt = DateFormat('HH:mm');
    const axisStyle = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondary,
    );

    final data = LineChartData(
      minX: 0,
      maxX: (points.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      backgroundColor: AppColors.chartPlotBg,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 25,
            getTitlesWidget: (value, meta) =>
                Text('${value.toInt()}%', style: axisStyle),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 4,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= points.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(timeFmt.format(points[i].timestamp), style: axisStyle),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.textPrimary,
          fitInsideHorizontally: true,
          getTooltipItems: (spots) {
            return [
              for (var n = 0; n < spots.length; n++)
                () {
                  final s = spots[n];
                  final key = ParamKey.values[s.barIndex];
                  final spec = Thresholds.specOf(key);
                  final real = points[s.spotIndex].valueOf(key);
                  final prefix = n == 0
                      ? '${timeFmt.format(points[s.spotIndex].timestamp)}\n'
                      : '';
                  return LineTooltipItem(
                    '$prefix${chartLabelOf(key)}: ${spec.format(real)} ${spec.unit}',
                    TextStyle(
                      color: chartColorOf(key),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  );
                }(),
            ];
          },
        ),
      ),
      lineBarsData: [for (final key in ParamKey.values) _line(key)],
    );

    return SizedBox(
      height: wide ? 320 : 260,
      child: LineChart(data),
    );
  }
}
