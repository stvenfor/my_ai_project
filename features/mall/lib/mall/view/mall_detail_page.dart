import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_mall/mall/controller/mall_detail_controller.dart';
import 'package:module_mall/mall/theme/mall_theme.dart';

class MallDetailPage extends GetView<MallDetailController> {
  const MallDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.standard,
      backgroundColor: MallTheme.background,
      navBar: const AppNavBar(
        title: '商品详情',
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
          return Center(child: Text('商品不存在', style: MallTheme.caption));
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 16.h),
                children: [
                  _Cover(url: d.coverUrl, aspect: d.coverAspect),
                  ColoredBox(
                    color: MallTheme.surface,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.title,
                            style: MallTheme.cardTitle.copyWith(fontSize: 18),
                          ),
                          SizedBox(height: 8.h),
                          Obx(() {
                            final price =
                                controller.selectedSku.value?.priceLabel ??
                                (d.skus.isEmpty ? '—' : d.skus.first.priceLabel);
                            return Text(
                              price,
                              style: MallTheme.priceText.copyWith(fontSize: 22),
                            );
                          }),
                          SizedBox(height: 8.h),
                          Text(
                            d.isVirtual ? '虚拟商品 · 支付后发放' : '实体商品 · 需填写收货信息',
                            style: MallTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!d.isVirtual) ...[
                    SizedBox(height: 8.h),
                    ColoredBox(
                      color: MallTheme.surface,
                      child: InkWell(
                        onTap: controller.pickAddress,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                          child: Obx(() {
                            final has = controller.hasAddress;
                            return Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 20.sp,
                                  color: MallTheme.accent,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: has
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${controller.receiverName.value}  ${controller.receiverPhone.value}',
                                              style: MallTheme.cardTitle,
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              controller.receiverAddress.value,
                                              style: MallTheme.caption,
                                            ),
                                          ],
                                        )
                                      : Text(
                                          '选择收货地址',
                                          style: MallTheme.tabInactive,
                                        ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: MallTheme.labelTertiary,
                                  size: 20.sp,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  ColoredBox(
                    color: MallTheme.surface,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('规格', style: MallTheme.tabActive),
                          SizedBox(height: 12.h),
                          if (d.skus.isEmpty)
                            Text('暂无可售规格', style: MallTheme.caption)
                          else
                            Obx(() => Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: [
                                    for (final sku in d.skus)
                                      _SkuChip(
                                        label: sku.label,
                                        selected:
                                            controller.selectedSku.value?.skuId ==
                                            sku.skuId,
                                        onTap: () => controller.selectSku(sku),
                                      ),
                                  ],
                                )),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Text('数量', style: MallTheme.tabActive),
                              const Spacer(),
                              Obx(() {
                                final sku = controller.selectedSku.value;
                                final stockHint = (sku == null || d.isVirtual)
                                    ? ''
                                    : '库存 ${sku.stockQty}';
                                return Text(stockHint, style: MallTheme.caption);
                              }),
                              SizedBox(width: 8.w),
                              _QtyStepper(
                                qty: controller.qty,
                                onMinus: () =>
                                    controller.setQty(controller.qty.value - 1),
                                onPlus: () =>
                                    controller.setQty(controller.qty.value + 1),
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
            _BottomBar(
              submitting: controller.submitting,
              onCart: controller.addToCart,
              onBuy: controller.buyNow,
            ),
          ],
        );
      }),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.aspect});

  final String url;
  final double aspect;

  @override
  Widget build(BuildContext context) {
    final ratio = 1 / aspect.clamp(0.7, 1.45);
    return ColoredBox(
      color: MallTheme.surface,
      child: AspectRatio(
        aspectRatio: ratio,
        child: url.isEmpty
            ? Icon(Icons.shopping_bag_outlined, color: MallTheme.labelTertiary, size: 48.sp)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shopping_bag_outlined,
                  color: MallTheme.labelTertiary,
                  size: 48.sp,
                ),
              ),
      ),
    );
  }
}

class _SkuChip extends StatelessWidget {
  const _SkuChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MallTheme.chipSelectedBg : MallTheme.background,
      borderRadius: BorderRadius.circular(MallTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MallTheme.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MallTheme.radiusMd),
            border: Border.all(
              color: selected ? MallTheme.accent : MallTheme.separator,
            ),
          ),
          child: Text(
            label,
            style: selected ? MallTheme.tabActive.copyWith(color: MallTheme.accent) : MallTheme.tabInactive,
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final RxInt qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onMinus),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text('${qty.value}', style: MallTheme.cardTitle),
          ),
          _StepBtn(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28.w,
        height: 28.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: MallTheme.separator),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16.sp, color: MallTheme.labelPrimary),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.submitting,
    required this.onCart,
    required this.onBuy,
  });

  final RxBool submitting;
  final VoidCallback onCart;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: MallTheme.surface,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h + bottom),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: MallTheme.separator)),
        ),
        child: Obx(() {
          final busy = submitting.value;
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onCart,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MallTheme.labelPrimary,
                    side: const BorderSide(color: MallTheme.separator),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: const Text('加入购物车'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FilledButton(
                  onPressed: busy ? null : onBuy,
                  style: FilledButton.styleFrom(
                    backgroundColor: MallTheme.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(busy ? '处理中…' : '立即购买'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
