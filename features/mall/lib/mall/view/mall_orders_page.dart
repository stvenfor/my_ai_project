import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_mall/mall/controller/mall_orders_controller.dart';
import 'package:module_mall/mall/model/mall_order.dart';
import 'package:module_mall/mall/theme/mall_theme.dart';
import 'package:module_mall/mall/view/widgets/mall_pay_countdown.dart';

class MallOrdersPage extends GetView<MallOrdersController> {
  const MallOrdersPage({super.key});

  static const _tabs = [
    (MallOrderTab.all, '全部'),
    (MallOrderTab.unpaid, '待支付'),
    (MallOrderTab.paid, '已支付'),
    (MallOrderTab.cancelled, '已取消'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.standard,
      backgroundColor: MallTheme.background,
      navBar: const AppNavBar(
        title: '我的订单',
        showBackButton: true,
        backgroundColor: MallTheme.surface,
        foregroundColor: MallTheme.labelPrimary,
      ),
      body: Column(
        children: [
          ColoredBox(
            color: MallTheme.surface,
            child: Obx(() {
              final current = controller.tab.value;
              return Row(
                children: [
                  for (final t in _tabs)
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.switchTab(t.$1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Column(
                            children: [
                              Text(
                                t.$2,
                                style: current == t.$1
                                    ? MallTheme.tabActive
                                    : MallTheme.tabInactive,
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                height: 2,
                                width: 28.w,
                                color: current == t.$1
                                    ? MallTheme.accent
                                    : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final err = controller.errorMessage.value;
              if (err.isNotEmpty && controller.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(err, style: MallTheme.caption),
                      SizedBox(height: 12.h),
                      TextButton(onPressed: controller.load, child: const Text('重试')),
                    ],
                  ),
                );
              }
              if (controller.items.isEmpty) {
                return Center(child: Text('暂无订单', style: MallTheme.caption));
              }
              return RefreshIndicator(
                onRefresh: controller.load,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 80) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                    itemCount: controller.items.length +
                        (controller.loadingMore.value ? 1 : 0),
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) {
                      if (i >= controller.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final row = controller.items[i];
                      return _OrderCard(
                        row: row,
                        onTap: () => controller.openDetail(row),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.row, required this.onTap});

  final MallOrderListRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MallTheme.surface,
      borderRadius: BorderRadius.circular(MallTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MallTheme.radiusMd),
        child: Container(
          decoration: MallTheme.cardDecoration,
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 72.w,
                  height: 72.w,
                  child: row.primaryCover.isEmpty
                      ? ColoredBox(
                          color: MallTheme.separator,
                          child: Icon(Icons.shopping_bag_outlined,
                              color: MallTheme.labelTertiary, size: 28.w),
                        )
                      : Image.network(
                          row.primaryCover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: MallTheme.separator,
                            child: Icon(Icons.broken_image_outlined,
                                color: MallTheme.labelTertiary, size: 28.w),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            row.primaryTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: MallTheme.cardTitle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(row.statusLabel, style: MallTheme.caption),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '共${row.totalQty}件 · ${row.orderNo}',
                      style: MallTheme.caption,
                    ),
                    if (row.isUnpaid && row.payDeadline != null) ...[
                      SizedBox(height: 4.h),
                      MallPayCountdown(
                        deadline: row.payDeadline!,
                        onExpired: () =>
                            Get.find<MallOrdersController>().load(),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('¥${row.amount}', style: MallTheme.priceText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
