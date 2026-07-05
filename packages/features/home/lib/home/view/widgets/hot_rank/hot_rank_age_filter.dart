import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/hot_rank_detail_controller.dart';
import 'package:module_home/home/model/hot_rank_detail_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class HotRankAgeFilterBar extends GetView<HotRankDetailController> {
  const HotRankAgeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pageState = controller.state.value;
      if (pageState == null) return const SizedBox.shrink();

      final selected = pageState.selectedAgeFilter;
      final showMenu = pageState.showAgeFilterMenu;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: controller.toggleAgeFilterMenu,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: DubbingHomeTheme.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selected.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DubbingHomeTheme.titleBlack,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    showMenu ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16.sp,
                    color: DubbingHomeTheme.subtitleGray,
                  ),
                ],
              ),
            ),
          ),
          if (showMenu)
            Positioned(
              top: 36.h,
              right: 0,
              child: Material(
                elevation: 8,
                shadowColor: DubbingHomeTheme.hotRankDropdownShadow,
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
                child: SizedBox(
                  width: 120.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < HotRankAgeFilter.values.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: DubbingHomeTheme.divider,
                          ),
                        Builder(
                          builder: (context) {
                            final filter = HotRankAgeFilter.values[i];
                            return GestureDetector(
                              onTap: () => controller.selectAgeFilter(filter),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                child: Text(
                                  filter.label,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: DubbingHomeTheme.titleBlack,
                                    fontWeight: filter == selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
