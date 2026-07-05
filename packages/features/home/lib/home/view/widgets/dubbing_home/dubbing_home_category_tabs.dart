import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeCategoryTabs extends GetView<DubbingHomeController> {
  const DubbingHomeCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 4.w, 4.h),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final selected = controller.selectedCategory.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final category in DubbingHomeCategory.values)
                      Padding(
                        padding: EdgeInsets.only(right: 24.w),
                        child: GestureDetector(
                          onTap: () => controller.onCategorySelected(category),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.label,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: selected == category
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _labelColor(category, selected == category),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: selected == category ? 24.w : 0,
                                height: 3.h,
                                decoration: BoxDecoration(
                                  color: DubbingHomeTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: Image.asset(
                DubbingHomeAssets.path('icon_menu.png'),
                package: DubbingHomeAssets.package,
                width: 22.w,
                height: 22.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _labelColor(DubbingHomeCategory category, bool selected) {
    if (category == DubbingHomeCategory.svip) {
      return DubbingHomeTheme.svipGold;
    }
    if (selected) {
      return DubbingHomeTheme.primaryGreen;
    }
    return DubbingHomeTheme.textGray;
  }
}
