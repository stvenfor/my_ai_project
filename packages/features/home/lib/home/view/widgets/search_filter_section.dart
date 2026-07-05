import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/search_controller.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_tag_chip.dart';
import 'package:module_utils/module_utils.dart';

class SearchFilterSection extends GetView<HomeSearchController> {
  const SearchFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tags = controller.filterTags.toList();

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '筛选',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: SearchPageTheme.titleBlack,
                  ),
                ),
                SizedBox(width: 6.w),
                Image.asset(
                  SearchAssets.path('icon_filter.png'),
                  package: SearchAssets.package,
                  width: 16.w,
                  height: 16.w,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final tag in tags)
                  SearchTagChip(
                    label: tag,
                    onTap: () => controller.onTagTap(tag),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
