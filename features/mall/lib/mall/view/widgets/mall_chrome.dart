import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_mall/mall/controller/mall_controller.dart';
import 'package:module_mall/mall/theme/mall_theme.dart';

/// 顶栏：返回 + 搜索（浅色 Design）
class MallSearchHeader extends StatelessWidget {
  const MallSearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final controller = Get.find<MallController>();

    return Container(
      color: MallTheme.surface,
      padding: EdgeInsets.fromLTRB(4.w, top + 4.h, 12.w, 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            icon: Icon(
              CupertinoIcons.back,
              color: MallTheme.labelPrimary,
              size: 22.sp,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: controller.onSearchTap,
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                  color: MallTheme.background,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: MallTheme.separator),
                ),
                padding: EdgeInsets.only(left: 10.w, right: 4.w),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 16.sp,
                      color: MallTheme.labelTertiary,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.searchHint.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MallTheme.searchHint,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.onSearchTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: MallTheme.accent,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '搜索',
                          style: TextStyle(
                            fontFamily: VercelTypography.fontFamily,
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MallCategoryTabs extends StatelessWidget {
  const MallCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MallController>();
    return Container(
      color: MallTheme.surface,
      height: 42.h,
      child: Obx(() {
        final selected = controller.categoryIndex.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          itemCount: MallController.categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 18.w),
          itemBuilder: (context, index) {
            final active = index == selected;
            return GestureDetector(
              onTap: () => controller.selectCategory(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    MallController.categories[index],
                    style: active ? MallTheme.tabActive : MallTheme.tabInactive,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 16.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: active ? MallTheme.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

class MallFilterBar extends StatelessWidget {
  const MallFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MallController>();
    return Container(
      color: MallTheme.background,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      child: Obx(() {
        final selected = controller.filterIndex.value;
        return Row(
          children: List.generate(MallController.filters.length, (index) {
            final active = index == selected;
            final label = MallController.filters[index];
            final showArrow = label == '积分' || label == '筛选';
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: GestureDetector(
                  onTap: () => controller.selectFilter(index),
                  child: Container(
                    height: 30.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? MallTheme.chipSelectedBg : MallTheme.surface,
                      borderRadius: BorderRadius.circular(MallTheme.radiusMd),
                      border: Border.all(
                        color: active ? MallTheme.accent : MallTheme.separator,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (active)
                          Icon(
                            Icons.check,
                            size: 12.sp,
                            color: MallTheme.accent,
                          ),
                        if (active) SizedBox(width: 2.w),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: VercelTypography.fontFamily,
                            color: active
                                ? MallTheme.accent
                                : MallTheme.labelSecondary,
                            fontSize: 12.sp,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (showArrow) ...[
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 14.sp,
                            color: active
                                ? MallTheme.accent
                                : MallTheme.labelTertiary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class MallFloatBottomBar extends StatelessWidget {
  const MallFloatBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MallController>();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 48.w,
      right: 48.w,
      bottom: bottom + 12.h,
      child: Material(
        color: MallTheme.surface,
        borderRadius: BorderRadius.circular(28.r),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: MallTheme.separator),
          ),
          child: Row(
            children: [
              Expanded(
                child: _FloatItem(
                  icon: Icons.verified_user_outlined,
                  label: '会员权益',
                  onTap: () => controller.onFloatTap('会员权益'),
                ),
              ),
              Container(
                width: 1,
                height: 24.h,
                color: MallTheme.separator,
              ),
              Expanded(
                child: _FloatItem(
                  icon: Icons.storefront_outlined,
                  label: '颜选好物',
                  onTap: () => controller.onFloatTap('颜选好物'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatItem extends StatelessWidget {
  const _FloatItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp, color: MallTheme.accent),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: VercelTypography.fontFamily,
              color: MallTheme.labelPrimary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
