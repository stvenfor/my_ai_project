import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_cover_image.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_section_header.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeRecentLearning extends GetView<DubbingHomeController> {
  const DubbingHomeRecentLearning({
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
          title: '最近在学',
          style: DubbingSectionHeaderStyle.chevron,
        ),
        SizedBox(
          height: 118.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => controller.onMediaTap(item),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 120.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DubbingCoverImage(
                        asset: item.coverAsset,
                        width: 120.w,
                        height: 68.h,
                        duration: item.duration,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DubbingHomeTheme.titleBlack,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
