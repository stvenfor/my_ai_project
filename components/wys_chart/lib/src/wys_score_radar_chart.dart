import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wys_chart/src/wys_chart_colors.dart';
import 'package:wys_chart/src/wys_chart_models.dart';

/// Radar on a fixed 0–100 scale. Prefer ≥3 entries for a readable shape.
class WysScoreRadarChart extends StatelessWidget {
  const WysScoreRadarChart({
    super.key,
    required this.data,
    required this.colors,
    this.height = 200,
    this.animate = true,
  });

  final List<WysRadarDatum> data;
  final WysChartColors colors;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final entries = data.isEmpty
        ? const [
            WysRadarDatum(label: '—', value: 0),
            WysRadarDatum(label: '—', value: 0),
            WysRadarDatum(label: '—', value: 0),
          ]
        : data;

    return SizedBox(
      height: height,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: colors.primary.withValues(alpha: 0.18),
              borderColor: colors.primary,
              entryRadius: 3,
              borderWidth: 2,
              dataEntries: [
                for (final d in entries)
                  RadarEntry(value: d.value.clamp(0, 100)),
              ],
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: BorderSide(color: colors.grid, width: 1),
          tickBorderData: BorderSide(color: colors.grid.withValues(alpha: 0.7)),
          gridBorderData: BorderSide(color: colors.grid, width: 1),
          ticksTextStyle: TextStyle(color: colors.muted, fontSize: 9),
          tickCount: 4,
          titlePositionPercentageOffset: 0.18,
          getTitle: (index, angle) {
            if (index < 0 || index >= entries.length) {
              return const RadarChartTitle(text: '');
            }
            return RadarChartTitle(
              text: entries[index].label,
              angle: angle,
            );
          },
          titleTextStyle: TextStyle(
            color: colors.foreground,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        duration:
            animate ? const Duration(milliseconds: 700) : Duration.zero,
      ),
    );
  }
}
