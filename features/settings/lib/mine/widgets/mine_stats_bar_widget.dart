import 'package:flutter/material.dart';
import 'package:module_settings/mine/model/mine_stat_model.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';

class MineStatsBarWidget extends StatelessWidget {
  const MineStatsBarWidget({super.key, required this.stats});

  final List<MineStatModel> stats;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: MineTheme.groupedCardDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Row(
          children: stats
              .map(
                (s) => Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.value, style: MineTheme.statValue),
                      const SizedBox(height: 6),
                      Text(s.label, style: MineTheme.caption),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
