import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/hot_rank_detail_controller.dart';
import 'package:module_home/home/model/hot_rank_detail_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class HotRankSidebar extends GetView<HotRankDetailController> {
  const HotRankSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pageState = controller.state.value;
      if (pageState == null) return const SizedBox.shrink();

      final selected = pageState.selectedCategory;
      final categories = pageState.categories.toList();

      return Container(
        width: 88.w,
        color: DubbingHomeTheme.hotRankSidebarBg,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isActive = category == selected;
            return _SidebarItem(
              category: category,
              isActive: isActive,
              onTap: () => controller.selectCategory(category),
            );
          },
        ),
      );
    });
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.category,
    required this.isActive,
    required this.onTap,
  });

  final HotRankCategory category;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isActive ? DubbingHomeTheme.hotRankSidebarActive : Colors.transparent,
          borderRadius: isActive
              ? BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  bottomLeft: Radius.circular(8.r),
                )
              : BorderRadius.circular(8.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (isActive && category == HotRankCategory.hotSearch)
              Positioned(
                top: -18.h,
                child: Image.asset(
                  HotRankDetailAssets.path('badge_top20.png'),
                  package: HotRankDetailAssets.package,
                  width: 36.w,
                  height: 16.h,
                  fit: BoxFit.contain,
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isActive) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        DubbingHomeAssets.path('wheat_left.png'),
                        package: DubbingHomeAssets.package,
                        width: 10.w,
                        height: 12.h,
                        fit: BoxFit.contain,
                        color: DubbingHomeTheme.svipGold,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      SizedBox(width: 2.w),
                      Image.asset(
                        DubbingHomeAssets.path('wheat_right.png'),
                        package: DubbingHomeAssets.package,
                        width: 10.w,
                        height: 12.h,
                        fit: BoxFit.contain,
                        color: DubbingHomeTheme.svipGold,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
                Text(
                  category.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? DubbingHomeTheme.titleBlack
                        : DubbingHomeTheme.textGray,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
