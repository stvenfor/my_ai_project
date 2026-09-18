import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wys_chart/src/wys_chart_colors.dart';
import 'package:wys_chart/src/wys_chart_models.dart';

/// Side-by-side comparison bars (e.g. revenue vs cost).
class WysCompareBarChart extends StatelessWidget {
  const WysCompareBarChart({
    super.key,
    required this.data,
    required this.colors,
    this.height = 160,
    this.animate = true,
  });

  final List<WysBarDatum> data;
  final WysChartColors colors;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final rawMax = data.fold<double>(0, (m, d) => d.value > m ? d.value : m);
    final maxY = rawMax > 0 ? rawMax * 1.15 : 1.0;
    final palette = [colors.success, colors.destructive, colors.accent];

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
                  '$label\n${rod.toY.toStringAsFixed(2)}',
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
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == 0) {
                    return Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(color: colors.muted, fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
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
                    width: 36,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    color: data[i].color ?? palette[i % palette.length],
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
}
