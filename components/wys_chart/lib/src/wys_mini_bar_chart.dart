import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wys_chart/src/wys_chart_colors.dart';
import 'package:wys_chart/src/wys_chart_models.dart';

/// Compact bars normalized so [baseMax] (typically PV) maps to 100% height.
class WysMiniBarChart extends StatelessWidget {
  const WysMiniBarChart({
    super.key,
    required this.data,
    required this.baseMax,
    required this.colors,
    this.height = 48,
    this.animate = true,
  });

  final List<WysBarDatum> data;
  final double baseMax;
  final WysChartColors colors;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final maxY = baseMax > 0 ? baseMax : 1.0;
    final palette = [
      colors.primary,
      colors.secondary,
      colors.accent,
      colors.success,
    ];

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 16,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      data[i].label,
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value.clamp(0, maxY),
                    width: 10,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    color: data[i].color ?? palette[i % palette.length],
                  ),
                ],
              ),
          ],
        ),
        duration:
            animate ? const Duration(milliseconds: 500) : Duration.zero,
      ),
    );
  }
}
