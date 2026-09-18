import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wys_chart/src/wys_chart_colors.dart';

/// Donut showing a 0–1 conversion rate (`转化 ÷ 点击`). Null / invalid → "—".
class WysConversionRing extends StatelessWidget {
  const WysConversionRing({
    super.key,
    required this.rate,
    required this.colors,
    this.size = 56,
    this.strokeWidth = 7,
    this.label = '转化率',
    this.animate = true,
  });

  final double? rate;
  final WysChartColors colors;
  final double size;
  final double strokeWidth;
  final String label;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final valid = rate != null && rate!.isFinite && rate! >= 0;
    final clamped = valid ? rate!.clamp(0.0, 1.0) : 0.0;
    final centerText = valid ? '${(clamped * 100).round()}%' : '—';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.28,
              sections: [
                PieChartSectionData(
                  value: valid ? (clamped <= 0 ? 0.0001 : clamped) : 0.0001,
                  color: colors.primary,
                  radius: strokeWidth + 2,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: valid ? (1 - clamped).clamp(0.0001, 1.0) : 1,
                  color: colors.grid,
                  radius: strokeWidth,
                  showTitle: false,
                ),
              ],
            ),
            duration: animate
                ? const Duration(milliseconds: 600)
                : Duration.zero,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerText,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(height: size * 0.02),
              Text(
                label,
                style: TextStyle(
                  color: colors.muted,
                  fontSize: size * 0.11,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
