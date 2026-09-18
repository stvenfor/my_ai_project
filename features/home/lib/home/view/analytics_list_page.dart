import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/analytics_list_controller.dart';
import 'package:module_home/home/model/analytics_record_model.dart';
import 'package:module_home/home/theme/analytics_theme.dart';
import 'package:wys_chart/wys_chart.dart';
import 'package:wys_router/src/route/route_path.dart';

class AnalyticsListPage extends GetView<AnalyticsListController> {
  const AnalyticsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: AnalyticsTheme.background,
      navBar: const AppNavBar(title: '数据分析', showBackButton: true),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final items = controller.items.toList();
        final errorMessage = controller.errorMessage.value;
        final hasMore = controller.hasMore.value;
        final isLoadingMore = controller.isLoadingMore.value;
        final total = controller.total.value;
        final page = controller.currentPage.value;

        if (isLoading && items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AnalyticsTheme.primary),
          );
        }

        if (errorMessage != null && items.isEmpty) {
          return _ErrorState(
            message: errorMessage,
            onRetry: controller.loadInitial,
          );
        }

        if (items.isEmpty) {
          return _EmptyState(onRefresh: controller.refresh);
        }

        return Column(
          children: [
            _SummaryBar(page: page, total: total, count: items.length),
            Expanded(
              child: AppRefreshView(
                onRefresh: controller.refresh,
                onLoad: controller.loadMore,
                enableLoad: hasMore,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: items.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AnalyticsTheme.secondary,
                          ),
                        ),
                      );
                    }
                    final item = items[index];
                    return _AnalyticsListTile(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () => Get.toNamed(
                        RoutePath.homeDataAnalyticsDetail,
                        arguments: item.id,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.page,
    required this.total,
    required this.count,
  });

  final int page;
  final int total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AnalyticsTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AnalyticsTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights_outlined,
              size: 18, color: AnalyticsTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '已加载 $count / 共 $total · 第 $page 页',
              style: const TextStyle(
                color: AnalyticsTheme.muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AnalyticsTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'gRPC',
              style: TextStyle(
                color: AnalyticsTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsListTile extends StatelessWidget {
  const _AnalyticsListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final AnalyticsRecordModel item;
  final VoidCallback onTap;

  Color? get _cueColor {
    if (item.flagAnomaly) return AnalyticsTheme.destructive;
    if (item.flagFeatured) return AnalyticsTheme.accent;
    return null;
  }

  double? get _conversionRate {
    if (item.metricClick <= 0) return null;
    return item.metricConvert / item.metricClick;
  }

  @override
  Widget build(BuildContext context) {
    final cue = _cueColor;
    final pv = item.metricPv.toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: AnalyticsTheme.gridGap),
      child: Material(
        color: AnalyticsTheme.card,
        borderRadius: BorderRadius.circular(AnalyticsTheme.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cue != null)
                  Container(width: 4, color: cue)
                else
                  const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AnalyticsTheme.foreground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusChip(status: item.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AnalyticsTheme.muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            WysConversionRing(
                              rate: _conversionRate,
                              colors: AnalyticsTheme.chartColors,
                              size: 64,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: WysMiniBarChart(
                                baseMax: pv > 0 ? pv : 1,
                                colors: AnalyticsTheme.chartColors,
                                height: 64,
                                data: [
                                  WysBarDatum(
                                      label: 'PV',
                                      value: item.metricPv.toDouble()),
                                  WysBarDatum(
                                      label: 'UV',
                                      value: item.metricUv.toDouble()),
                                  WysBarDatum(
                                      label: '点',
                                      value: item.metricClick.toDouble()),
                                  WysBarDatum(
                                      label: '转',
                                      value: item.metricConvert.toDouble()),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _MetricPill(
                                label: 'UV', value: _compact(item.metricUv)),
                            const SizedBox(width: 8),
                            _MetricPill(
                              label: 'ROI',
                              value: item.metricRoi.toStringAsFixed(2),
                              accent: true,
                            ),
                            const Spacer(),
                            Text(
                              item.code,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: AnalyticsTheme.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: AnalyticsTheme.muted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _compact(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}w';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => AnalyticsTheme.success,
      'paused' => AnalyticsTheme.accent,
      'archived' => AnalyticsTheme.muted,
      _ => AnalyticsTheme.secondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (accent ? AnalyticsTheme.accent : AnalyticsTheme.secondary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: accent ? AnalyticsTheme.accent : AnalyticsTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AnalyticsTheme.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined,
                    size: 56, color: AnalyticsTheme.muted),
                SizedBox(height: 12),
                Text(
                  '暂无分析数据',
                  style: TextStyle(
                    color: AnalyticsTheme.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '下拉刷新，或确认 Go 端已写入种子数据',
                  style: TextStyle(color: AnalyticsTheme.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: AnalyticsTheme.destructive),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AnalyticsTheme.muted, fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: onRetry,
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
}
