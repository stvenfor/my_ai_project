import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_mall/mall/controller/mall_order_detail_controller.dart';
import 'package:module_mall/mall/theme/mall_theme.dart';
import 'package:module_mall/mall/view/widgets/mall_pay_countdown.dart';

class MallOrderDetailPage extends GetView<MallOrderDetailController> {
  const MallOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.standard,
      backgroundColor: MallTheme.background,
      navBar: AppNavBar(
        title: '订单详情',
        showBackButton: true,
        backgroundColor: MallTheme.surface,
        foregroundColor: MallTheme.labelPrimary,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final err = controller.errorMessage.value;
        if (err.isNotEmpty && controller.detail.value == null) {
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
        final d = controller.detail.value;
        if (d == null) {
          return Center(child: Text('订单不存在', style: MallTheme.caption));
        }
        final deadline = d.payDeadline;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                children: [
                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.statusLabel, style: MallTheme.tabActive),
                        if (d.isUnpaid && deadline != null) ...[
                          SizedBox(height: 8.h),
                          MallPayCountdown(
                            deadline: deadline,
                            onExpired: controller.onPayExpired,
                          ),
                        ],
                        SizedBox(height: 8.h),
                        InkWell(
                          onTap: () => controller.copyOrderNo(d.orderNo),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '订单号 ${d.orderNo}',
                                  style: MallTheme.caption,
                                ),
                              ),
                              Icon(Icons.copy, size: 16.w, color: MallTheme.accent),
                              SizedBox(width: 4.w),
                              Text(
                                '复制',
                                style: MallTheme.caption.copyWith(color: MallTheme.accent),
                              ),
                            ],
                          ),
                        ),
                        if (d.createdAt.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text('下单时间 ${d.createdAt}', style: MallTheme.caption),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _Section(
                    child: Column(
                      children: [
                        for (var i = 0; i < d.items.length; i++) ...[
                          if (i > 0) Divider(height: 20.h, color: MallTheme.separator),
                          _LineRow(
                            title: d.items[i].productTitle,
                            cover: d.items[i].coverUrl,
                            qty: d.items[i].qty,
                            amount: d.items[i].lineAmount,
                            contentUrl: d.items[i].contentUrl,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (d.hasReceiver) ...[
                    SizedBox(height: 10.h),
                    _Section(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('收货信息', style: MallTheme.cardTitle),
                          SizedBox(height: 8.h),
                          Text(
                            '${d.receiverName}  ${d.receiverPhone}',
                            style: MallTheme.caption.copyWith(
                              color: MallTheme.labelSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            d.receiverAddress,
                            style: MallTheme.caption.copyWith(
                              color: MallTheme.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 10.h),
                  _Section(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('实付金额', style: MallTheme.cardTitle),
                        Text('¥${d.amount}', style: MallTheme.priceText.copyWith(fontSize: 18)),
                      ],
                    ),
                  ),
                  if (d.isUnpaid &&
                      d.amount.trim().isNotEmpty &&
                      d.amount != '0' &&
                      d.amount != '0.00' &&
                      d.amount != '0.0') ...[
                    SizedBox(height: 10.h),
                    _Section(
                      child: Obx(() {
                        final ch = controller.selectedChannel.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('支付方式', style: MallTheme.cardTitle),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              children: [
                                ChoiceChip(
                                  label: const Text('支付宝'),
                                  selected: ch == MallOrderDetailController.payAlipay,
                                  onSelected: (_) => controller.selectedChannel.value =
                                      MallOrderDetailController.payAlipay,
                                ),
                                ChoiceChip(
                                  label: const Text('微信'),
                                  selected: ch == MallOrderDetailController.payWeChat,
                                  onSelected: (_) => controller.selectedChannel.value =
                                      MallOrderDetailController.payWeChat,
                                ),
                                ChoiceChip(
                                  label: Text('余额 ¥${controller.walletBalance.value}'),
                                  selected: ch == MallOrderDetailController.payBalance,
                                  onSelected: (_) => controller.selectedChannel.value =
                                      MallOrderDetailController.payBalance,
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            if (d.isUnpaid)
              SafeArea(
                top: false,
                child: ColoredBox(
                  color: MallTheme.surface,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
                    child: Obx(() {
                      final busy = controller.acting.value;
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: busy ? null : controller.cancel,
                              child: const Text('取消订单'),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: FilledButton(
                              onPressed: busy ? null : controller.pay,
                              style: FilledButton.styleFrom(
                                backgroundColor: MallTheme.accent,
                              ),
                              child: busy
                                  ? SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('去支付'),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: MallTheme.cardDecoration,
      child: child,
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.title,
    required this.cover,
    required this.qty,
    required this.amount,
    required this.contentUrl,
  });

  final String title;
  final String cover;
  final int qty;
  final String amount;
  final String contentUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 64.w,
            height: 64.w,
            child: cover.isEmpty
                ? ColoredBox(
                    color: MallTheme.separator,
                    child: Icon(Icons.shopping_bag_outlined,
                        color: MallTheme.labelTertiary, size: 24.w),
                  )
                : Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: MallTheme.separator,
                      child: Icon(Icons.broken_image_outlined,
                          color: MallTheme.labelTertiary, size: 24.w),
                    ),
                  ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: MallTheme.cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 6.h),
              Text('x$qty', style: MallTheme.caption),
              if (contentUrl.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  '履约：$contentUrl',
                  style: MallTheme.caption.copyWith(color: MallTheme.accent),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        Text('¥$amount', style: MallTheme.priceText),
      ],
    );
  }
}
