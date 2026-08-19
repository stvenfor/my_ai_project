import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';

class StrategyPage extends StatefulWidget {
  const StrategyPage({super.key});

  @override
  State<StrategyPage> createState() => _StrategyPageState();
}

class _StrategyPageState extends State<StrategyPage> {
  int _selectedTab = 0;
  int _periodIndex = 4;

  static const _tabs = ['推荐', '逆向', '趋势'];
  static const _periods = ['今年来', '近1周', '近1月', '近3月', '近1年'];

  static const _gridCells = [
    _GridCell('A股', '+19.22%', true),
    _GridCell('中债', '+3.15%', true),
    _GridCell('黄金', '+8.76%', true),
    _GridCell('港股', '+12.40%', true),
    _GridCell('美股', '+15.88%', true),
    _GridCell('原油', '-2.34%', false),
    _GridCell('美元债', '-1.80%', false),
    _GridCell('商品', '+4.56%', true),
    _GridCell('现金', '+1.20%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '策略', showBackButton: true),
      backgroundColor: HomeDashboardTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 840 ? 720.0 : double.infinity;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _buildSubTabs(),
                  const SizedBox(height: 16),
                  _buildAssetGridCard(),
                  const SizedBox(height: 16),
                  _buildStrategyCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_tabs.length, (index) {
        final active = index == _selectedTab;
        return GestureDetector(
          onTap: () => setState(() => _selectedTab = index),
          child: Padding(
            padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 32 : 0),
            child: Column(
              children: [
                Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? HomeDashboardTheme.labelPrimary
                        : HomeDashboardTheme.labelSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 24 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: HomeDashboardTheme.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAssetGridCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '「大类资产九宫格策略」通过分散配置降低波动，帮助你在不同市场环境下保持稳健收益。',
              style: HomeDashboardTheme.sectionLabel.copyWith(
                color: HomeDashboardTheme.labelPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.35,
              ),
              itemCount: _gridCells.length,
              itemBuilder: (context, index) {
                final cell = _gridCells[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cell.positive
                        ? const Color(0x14FF3B30)
                        : const Color(0x1434C759),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cell.label,
                        style: HomeDashboardTheme.sectionLabel.copyWith(
                          color: HomeDashboardTheme.labelPrimary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cell.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cell.positive
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFF34C759),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_periods.length, (index) {
                  final active = index == _periodIndex;
                  return Padding(
                    padding: EdgeInsets.only(right: index < _periods.length - 1 ? 16 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _periodIndex = index),
                      child: Text(
                        _periods[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active
                              ? HomeDashboardTheme.accent
                              : HomeDashboardTheme.labelSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '黄金恐贪定投 · 第一期',
                        style: HomeDashboardTheme.sectionTitle.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: HomeDashboardTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '逆向',
                          style: TextStyle(
                            fontSize: 11,
                            color: HomeDashboardTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '如何跟投',
                  style: TextStyle(
                    color: HomeDashboardTheme.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '-11.35%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF34C759),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text('本期收益率', style: HomeDashboardTheme.sectionLabel),
                  ],
                ),
                const Spacer(),
                _buildGauge(),
              ],
            ),
            const SizedBox(height: 20),
            Text('定投进度', style: HomeDashboardTheme.sectionLabel),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 36 / 50,
                    minHeight: 24,
                    backgroundColor: HomeDashboardTheme.fillSecondary,
                    color: HomeDashboardTheme.accent,
                  ),
                ),
                Text(
                  '36 / 50',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HomeDashboardTheme.labelPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '本周已投 1 份',
                    style: HomeDashboardTheme.sectionLabel,
                  ),
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: HomeDashboardTheme.accent,
                    minimumSize: const Size(72, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('订阅'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '在恐慌时买入、贪婪时卖出，通过定期定额降低择时压力，适合长期持有的投资者。',
              style: HomeDashboardTheme.sectionLabel.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge() {
    return SizedBox(
      width: 88,
      height: 56,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: const Size(88, 44),
            painter: _GaugePainter(),
          ),
          Text(
            '63 中立',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HomeDashboardTheme.labelPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridCell {
  const _GridCell(this.label, this.value, this.positive);
  final String label;
  final String value;
  final bool positive;
}

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    const start = 3.14;
    const sweep = 3.14;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    paint.shader = const SweepGradient(
      colors: [Color(0xFF34C759), Color(0xFFFFCC00), Color(0xFFFF3B30)],
      startAngle: start,
      endAngle: start + sweep,
    ).createShader(rect);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: 36),
      start,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
