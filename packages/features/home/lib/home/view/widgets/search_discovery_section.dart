import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/search_controller.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_tag_chip.dart';
import 'package:module_utils/module_utils.dart';

class SearchDiscoverySection extends GetView<HomeSearchController> {
  const SearchDiscoverySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final discovery = controller.searchDiscovery.toList();

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '搜索发现',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: SearchPageTheme.titleBlack,
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: controller.refreshDiscovery,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Image.asset(
                      SearchAssets.path('icon_refresh.png'),
                      package: SearchAssets.package,
                      width: 16.w,
                      height: 16.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 8.w) / 2;
                return Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final tag in discovery)
                      SizedBox(
                        width: itemWidth,
                        child: SearchTagChip(
                          label: tag,
                          expand: true,
                          onTap: () => controller.onTagTap(tag),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
