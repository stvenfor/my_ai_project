import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/after_sales/model/after_sales_models.dart';
import 'package:module_home/after_sales/theme/after_sales_theme.dart';
import 'package:module_home/after_sales/viewmodel/after_sales_list_viewmodel.dart';
import 'package:module_home/after_sales/widgets/after_sales_skeleton.dart';
import 'package:wys_router/src/route/route_path.dart';

class AfterSalesListPage extends GetView<AfterSalesListViewModel> {
  const AfterSalesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: AfterSalesTheme.background,
      navBar: AppNavBar(
        title: '售后专区',
        showBackButton: true,
        backgroundColor: AfterSalesTheme.surface,
        foregroundColor: AfterSalesTheme.ink,
        actions: [
          Obx(() {
            if (!controller.canCreate.value) return const SizedBox.shrink();
            return IconButton(
              tooltip: '新建记录',
              onPressed: () async {
                final ok = await Get.toNamed(RoutePath.homeAfterSalesCreate);
                if (ok == true) controller.refreshAll();
              },
              icon: const Icon(Icons.add_circle_outline),
            );
          }),
        ],
      ),
      body: Obx(() {
        final loading = controller.loading.value;
        final items = controller.items.toList();
        final appointments = controller.appointments.toList();
        final err = controller.error.value;
        final canCreate = controller.canCreate.value;

        if (loading && items.isEmpty) {
          return const AfterSalesListSkeleton();
        }
        if (err.isNotEmpty && items.isEmpty) {
          return _EmptyState(
            icon: Icons.error_outline,
            title: '加载失败',
            message: err,
            actionLabel: '重试',
            onAction: controller.refreshAll,
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          child: AppRefreshView(
            key: ValueKey('list-${items.length}-$canCreate'),
            onRefresh: controller.refreshAll,
            onLoad: controller.loadMore,
            enableLoad: controller.hasMore.value,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AfterSalesFadeSlideIn(
                    index: 0,
                    child: _HeroHeader(
                      recordCount: items.length,
                      pendingCount: appointments.length,
                      canCreate: canCreate,
                    ),
                  ),
                ),
                if (canCreate && appointments.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: AfterSalesFadeSlideIn(
                      index: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Text('待处理预约', style: AfterSalesTheme.sectionTitle),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverList.separated(
                      itemCount: appointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final a = appointments[i];
                        return AfterSalesFadeSlideIn(
                          index: i + 2,
                          child: _AppointmentCard(
                            appointment: a,
                            onTap: () async {
                              final ok = await Get.toNamed(
                                RoutePath.homeAfterSalesCreate,
                                arguments: {
                                  'appointment_id': a.appointmentId,
                                  'customer_name': a.customerName,
                                },
                              );
                              if (ok == true) controller.refreshAll();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: AfterSalesFadeSlideIn(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Text(
                        canCreate ? '维修保养记录' : '我的服务记录',
                        style: AfterSalesTheme.sectionTitle,
                      ),
                    ),
                  ),
                ),
                if (items.isEmpty)
                  const AfterSalesEmptySliver()
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    sliver: SliverList.separated(
                      itemCount: items.length + (loading ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AfterSalesTheme.accent,
                                ),
                              ),
                            ),
                          );
                        }
                        final item = items[i];
                        return AfterSalesFadeSlideIn(
                          index: i + 3,
                          child: _RecordCard(
                            record: item,
                            onTap: () => Get.toNamed(
                              RoutePath.homeAfterSalesDetail,
                              arguments: item.recordId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// 空态占位（避免 const + getter style 冲突）。
class AfterSalesEmptySliver extends StatelessWidget {
  const AfterSalesEmptySliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: _EmptyState(
        icon: Icons.build_circle_outlined,
        title: '暂无记录',
        message: '完成售后服务后，在这里沉淀维修保养档案',
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.recordCount,
    required this.pendingCount,
    required this.canCreate,
  });

  final int recordCount;
  final int pendingCount;
  final bool canCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AfterSalesTheme.accentDeep, AfterSalesTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '维修保养档案',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      canCreate ? '当前店服务记录与预约跟进' : '查看与您相关的服务记录',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStat(label: '记录', value: '$recordCount'),
              if (canCreate) ...[
                Container(width: 1, height: 28, color: Colors.white24),
                _HeroStat(label: '待预约', value: '$pendingCount'),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.onTap});
  final AfterSalesAppointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AfterSalesTheme.surface,
      borderRadius: BorderRadius.circular(AfterSalesTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AfterSalesTheme.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AfterSalesTheme.radiusCard),
            border: Border.all(color: AfterSalesTheme.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AfterSalesTheme.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event_available_outlined,
                    color: AfterSalesTheme.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.customerName, style: AfterSalesTheme.title),
                    const SizedBox(height: 4),
                    Text('预约日 ${appointment.appointmentDate}', style: AfterSalesTheme.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AfterSalesTheme.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '建档',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onTap});
  final AfterSalesRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kindColor = AfterSalesTheme.kindColor(record.serviceKind);
    return Material(
      color: AfterSalesTheme.surface,
      borderRadius: BorderRadius.circular(AfterSalesTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AfterSalesTheme.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AfterSalesTheme.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kindColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AfterSalesTheme.radiusChip),
                    ),
                    child: Text(
                      record.serviceKindLabel.isEmpty
                          ? (record.serviceKind == 0 ? '维修' : '保养')
                          : record.serviceKindLabel,
                      style: TextStyle(
                        color: kindColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(record.serviceDate, style: AfterSalesTheme.caption),
                ],
              ),
              const SizedBox(height: 10),
              Hero(
                tag: 'after_sales_title_${record.recordId}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(record.title, style: AfterSalesTheme.title),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AfterSalesTheme.mute),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${record.customerName}  ${record.customerPhone}',
                      style: AfterSalesTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (record.plateNo.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.directions_car_outlined,
                        size: 16, color: AfterSalesTheme.mute),
                    const SizedBox(width: 4),
                    Text(record.plateNo, style: AfterSalesTheme.caption),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AfterSalesTheme.mute.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(title, style: AfterSalesTheme.title),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AfterSalesTheme.caption,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AfterSalesTheme.accent),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
