import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_cover_image.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_section_header.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeEditorPicks extends GetView<DubbingHomeController> {
  const DubbingHomeEditorPicks({
    super.key,
    required this.items,
  });

  final List<DubbingHomeMediaItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DubbingHomeSectionHeader(
          title: '小编精选',
          style: DubbingSectionHeaderStyle.refresh,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.68,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => controller.onMediaTap(item),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DubbingCoverImage(
                      asset: item.coverAsset,
                      width: double.infinity,
                      height: 96.h,
                      badge: item.badge,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: DubbingHomeTheme.titleBlack,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: DubbingHomeTheme.subtitleGray,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
