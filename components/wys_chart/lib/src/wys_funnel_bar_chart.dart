import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wys_chart/src/wys_chart_colors.dart';
import 'package:wys_chart/src/wys_chart_models.dart';

/// Funnel-style bars: [baseMax] (typically PV) is 100% of the Y axis.
class WysFunnelBarChart extends StatelessWidget {
  const WysFunnelBarChart({
    super.key,
    required this.data,
    required this.baseMax,
    required this.colors,
    this.height = 180,
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
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colors.foreground.withValues(alpha: 0.9),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = data[group.x.toInt()].label;
                return BarTooltipItem(
                  '$label\n${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colors.grid,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: maxY / 2,
                getTitlesWidget: (value, meta) {
                  if (value != 0 && value != maxY && (value - maxY / 2).abs() > 0.01) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    _compact(value),
                    style: TextStyle(color: colors.muted, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[i].label,
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
                    width: 22,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    color: data[i].color ?? palette[i % palette.length],
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: colors.grid.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
          ],
        ),
        duration:
            animate ? const Duration(milliseconds: 700) : Duration.zero,
      ),
    );
  }

  String _compact(double n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}w';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toStringAsFixed(0);
  }
}
