import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/analytics_detail_controller.dart';
import 'package:module_home/home/model/analytics_record_model.dart';
import 'package:module_home/home/theme/analytics_theme.dart';
import 'package:wys_chart/wys_chart.dart';

class AnalyticsDetailPage extends GetView<AnalyticsDetailController> {
  const AnalyticsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: AnalyticsTheme.background,
      navBar: const AppNavBar(title: '数据详情', showBackButton: true),
      body: Obx(() {
        if (controller.isLoading.value && controller.record.value == null) {
          return Center(
            child: CircularProgressIndicator(color: AnalyticsTheme.primary),
          );
        }
        final error = controller.errorMessage.value;
        if (error != null && controller.record.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AnalyticsTheme.muted),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: controller.loadDetail,
                      style: FilledButton.styleFrom(
                        backgroundColor: AnalyticsTheme.primary,
                        minimumSize: const Size(120, 44),
                      ),
                      child: const Text('重试'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final item = controller.record.value;
        if (item == null) return const SizedBox.shrink();

        final pv = item.metricPv.toDouble();
        final stickiness = _stickinessScore(item.metricBounceRate);

        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
          children: [
            if (item.flagAnomaly)
              _CueBanner(
                color: AnalyticsTheme.destructive,
                icon: Icons.warning_amber_rounded,
                title: '异常记录',
                subtitle: '该观测被标记为异常，请优先核对流量与转化。',
              )
            else if (item.flagFeatured)
              _CueBanner(
                color: AnalyticsTheme.accent,
                icon: Icons.star_rounded,
                title: '精选记录',
                subtitle: '该观测被标记为精选，适合作为对照样例。',
              ),
            if (item.flagAnomaly || item.flagFeatured)
              const SizedBox(height: 12),
            _HeroCard(item: item),
            const SizedBox(height: 12),
            _ChartSection(
              title: '流量漏斗',
              icon: Icons.filter_alt_outlined,
              child: WysFunnelBarChart(
                baseMax: pv > 0 ? pv : 1,
                colors: AnalyticsTheme.chartColors,
                data: [
                  WysBarDatum(label: 'PV', value: item.metricPv.toDouble()),
                  WysBarDatum(label: 'UV', value: item.metricUv.toDouble()),
                  WysBarDatum(label: '点击', value: item.metricClick.toDouble()),
                  WysBarDatum(
                      label: '转化', value: item.metricConvert.toDouble()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ChartSection(
              title: '收支对比',
              icon: Icons.payments_outlined,
              child: WysCompareBarChart(
                colors: AnalyticsTheme.chartColors,
                data: [
                  WysBarDatum(
                    label: '收入',
                    value: item.metricRevenue,
                    color: AnalyticsTheme.success,
                  ),
                  WysBarDatum(
                    label: '成本',
                    value: item.metricCost,
                    color: AnalyticsTheme.destructive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ChartSection(
              title: '质量 / 风险',
              icon: Icons.radar_outlined,
              child: WysScoreRadarChart(
                colors: AnalyticsTheme.chartColors,
                data: [
                  WysRadarDatum(label: '质量', value: item.scoreQuality),
                  WysRadarDatum(label: '风险', value: item.scoreRisk),
                  WysRadarDatum(label: '粘性', value: stickiness),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '概况',
              icon: Icons.badge_outlined,
              children: [
                _KV('编号', item.code, mono: true),
                _KV('分类', '${item.category} / ${item.subCategory}'),
                _KV('状态', item.status),
                _KV('优先级', '${item.priority}'),
                _KV('地区', item.region),
                _KV('渠道', item.channel),
                _KV('负责人', '${item.ownerName} · ${item.ownerTeam}'),
                _KV('来源', item.sourceSystem),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '流量指标',
              icon: Icons.trending_up,
              children: [
                _KV('PV', '${item.metricPv}', mono: true),
                _KV('UV', '${item.metricUv}', mono: true),
                _KV('点击', '${item.metricClick}', mono: true),
                _KV('转化', '${item.metricConvert}', mono: true),
                _KV('跳出率', item.metricBounceRate.toStringAsFixed(2), mono: true),
                _KV('平均停留(秒)', '${item.metricAvgDurationSec}', mono: true),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '财务指标',
              icon: Icons.payments_outlined,
              children: [
                _KV('收入', item.metricRevenue.toStringAsFixed(2), mono: true),
                _KV('成本', item.metricCost.toStringAsFixed(2), mono: true),
                _KV('ROI', item.metricRoi.toStringAsFixed(2),
                    mono: true, emphasize: true),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '评分与标签',
              icon: Icons.verified_outlined,
              children: [
                _KV('质量分', item.scoreQuality.toStringAsFixed(1), mono: true),
                _KV('风险分', item.scoreRisk.toStringAsFixed(1), mono: true),
                _KV('主标签', item.tagPrimary),
                _KV('次标签', item.tagSecondary),
                _KV('精选', item.flagFeatured ? '是' : '否'),
                _KV('异常', item.flagAnomaly ? '是' : '否',
                    danger: item.flagAnomaly),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '时间线（Unix 秒）',
              icon: Icons.schedule_outlined,
              children: [
                _TimeKV('观测', item.observedAt),
                _TimeKV('窗口开始', item.windowStart),
                _TimeKV('窗口结束', item.windowEnd),
                _TimeKV('发布', item.publishedAt),
                _TimeKV('创建', item.createdAt),
                _TimeKV('更新', item.updatedAt),
              ],
            ),
            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionCard(
                title: '备注',
                icon: Icons.notes_outlined,
                children: [
                  Text(
                    item.notes,
                    style: TextStyle(
                      color: AnalyticsTheme.foreground,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      }),
    );
  }

  /// Bounce as 0–1 or 0–100 → stickiness 0–100 (higher is better).
  static double _stickinessScore(double bounce) {
    if (!bounce.isFinite || bounce < 0) return 0;
    final rate = bounce <= 1 ? bounce : (bounce / 100).clamp(0.0, 1.0);
    return ((1 - rate) * 100).clamp(0, 100);
  }
}

class _CueBanner extends StatelessWidget {
  const _CueBanner({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AnalyticsTheme.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AnalyticsTheme.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AnalyticsTheme.card,
        borderRadius: BorderRadius.circular(AnalyticsTheme.cardRadius),
        border: Border.all(color: AnalyticsTheme.border),
        boxShadow: [
          BoxShadow(
            color: AnalyticsTheme.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AnalyticsTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AnalyticsTheme.foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.item});

  final AnalyticsRecordModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AnalyticsTheme.cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _HeroMetric(label: 'UV', value: '${item.metricUv}'),
              const SizedBox(width: 12),
              _HeroMetric(
                label: 'ROI',
                value: item.metricRoi.toStringAsFixed(2),
              ),
              const SizedBox(width: 12),
              _HeroMetric(
                label: '质量',
                value: item.scoreQuality.toStringAsFixed(0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: AnalyticsTheme.card,
        borderRadius: BorderRadius.circular(AnalyticsTheme.cardRadius),
        border: Border.all(color: AnalyticsTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AnalyticsTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AnalyticsTheme.foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV(
    this.label,
    this.value, {
    this.mono = false,
    this.emphasize = false,
    this.danger = false,
  });

  final String label;
  final String value;
  final bool mono;
  final bool emphasize;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(color: AnalyticsTheme.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: danger
                    ? AnalyticsTheme.destructive
                    : (emphasize
                        ? AnalyticsTheme.accent
                        : AnalyticsTheme.foreground),
                fontSize: 14,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeKV extends StatelessWidget {
  const _TimeKV(this.label, this.unix);

  final String label;
  final int unix;

  @override
  Widget build(BuildContext context) {
    return _KV(
      label,
      '${formatUnixSeconds(unix)}  ($unix)',
      mono: true,
    );
  }
}
