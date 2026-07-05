import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/search_controller.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_tag_chip.dart';
import 'package:module_utils/module_utils.dart';

class SearchHistorySection extends GetView<HomeSearchController> {
  const SearchHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = controller.searchHistory.toList();
      if (history.isEmpty) {
        return SizedBox(height: 8.h);
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: SearchPageTheme.titleBlack,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: controller.clearHistory,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        SearchAssets.path('icon_clear_history.png'),
                        package: SearchAssets.package,
                        width: 14.w,
                        height: 14.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '清除历史',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: SearchPageTheme.subtitleGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final tag in history)
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
