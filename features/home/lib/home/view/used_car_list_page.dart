import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/used_car_list_controller.dart';
import 'package:module_home/home/model/used_car_order_models.dart';
import 'package:wys_router/src/route/route_path.dart';

class UsedCarListPage extends GetView<UsedCarListController> {
  const UsedCarListPage({super.key});

  static const _bg = Color(0xFFF3F5F8);
  static const _ink = Color(0xFF1C2430);
  static const _accent = Color(0xFF0B6E4F);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bg,
      navBar: AppNavBar(
        title: '二手车',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: '新建',
            onPressed: () async {
              final ok = await Get.toNamed(RoutePath.homeUsedCarCreate);
              if (ok == true) controller.refresh();
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final items = controller.items.toList();
        final errorMessage = controller.errorMessage.value;
        final summary = controller.summary.value;

        if (isLoading && items.isEmpty && summary == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (errorMessage != null && items.isEmpty) {
          return _CenteredMessage(
            title: '加载失败',
            message: errorMessage,
            actionLabel: '重试',
            onAction: controller.loadInitial,
          );
        }

        return AppRefreshView(
          onRefresh: controller.refresh,
          onLoad: controller.loadMore,
          enableLoad: controller.hasMore.value,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _SummaryHeader(summary: summary)),
              SliverToBoxAdapter(
                child: _FilterBar(
                  status: controller.statusTab.value,
                  kind: controller.kindFilter.value,
                  onStatus: controller.setStatusTab,
                  onKind: controller.setKindFilter,
                ),
              ),
              if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _CenteredMessage(
                    title: '暂无业务单',
                    message: '点击右上角新建置换 / 专卖 / 收车单',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: items.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final item = items[index];
                      return _OrderCard(
                        item: item,
                        onTap: () => Get.toNamed(
                          RoutePath.homeUsedCarDetail,
                          arguments: item.orderId,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.summary});
  final UsedCarOrderSummary? summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B6E4F), Color(0xFF149E6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s?.displayName.isNotEmpty == true ? s!.displayName : '销售顾问',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (s?.positionLabel.isNotEmpty == true) s!.positionLabel,
              if (s?.storeName.isNotEmpty == true) s!.storeName,
            ].join(' · '),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatChip(label: '已提交', value: s?.stats.submitted ?? 0),
              _StatChip(label: '待审核', value: s?.stats.pendingReview ?? 0),
              _StatChip(label: '已通过', value: s?.stats.approved ?? 0),
              _StatChip(label: '未通过', value: s?.stats.rejected ?? 0),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.status,
    required this.kind,
    required this.onStatus,
    required this.onKind,
  });

  final UsedCarStatusTab status;
  final UsedCarKindFilter kind;
  final ValueChanged<UsedCarStatusTab> onStatus;
  final ValueChanged<UsedCarKindFilter> onKind;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final tab in UsedCarStatusTab.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tab.label),
                      selected: status == tab,
                      onSelected: (_) => onStatus(tab),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final k in UsedCarKindFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(k.label),
                      selected: kind == k,
                      onSelected: (_) => onKind(k),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.item, required this.onTap});
  final UsedCarOrderItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x140B6E4F),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.kindLabel,
                      style: const TextStyle(
                        color: UsedCarListPage._accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item.statusLabel, style: const TextStyle(fontSize: 12)),
                  ),
                  const Spacer(),
                  Text(
                    item.submittedAt.toLocal().toString().substring(0, 10),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.vehicleModel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: UsedCarListPage._ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.plateNo} · ${item.modelYear}款 · ${item.mileageKm}km',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    item.amountLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '¥${item.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: UsedCarListPage._ink,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.customerName,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
