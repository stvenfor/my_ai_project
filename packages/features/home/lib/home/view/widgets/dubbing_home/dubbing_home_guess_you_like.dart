import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_cover_image.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_section_header.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeGuessYouLike extends GetView<DubbingHomeController> {
  const DubbingHomeGuessYouLike({
    super.key,
    required this.items,
  });

  final List<DubbingHomeMediaItem> items;

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DubbingHomeSectionHeader(
          title: '猜你喜欢',
          style: DubbingSectionHeaderStyle.refresh,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < displayItems.length; i++) ...[
                if (i > 0) SizedBox(width: 12.w),
                Expanded(
                  child: _GuessCard(
                    item: displayItems[i],
                    onTap: () => controller.onMediaTap(displayItems[i]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GuessCard extends StatelessWidget {
  const _GuessCard({
    required this.item,
    required this.onTap,
  });

  final DubbingHomeMediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DubbingCoverImage(
            asset: item.coverAsset,
            width: double.infinity,
            height: 110.h,
            duration: item.duration,
          ),
          SizedBox(height: 8.h),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: DubbingHomeTheme.titleBlack,
              height: 1.3,
            ),
          ),
          if (item.playCount != null) ...[
            SizedBox(height: 4.h),
            Text(
              '${item.playCount}播放',
              style: TextStyle(
                fontSize: 11.sp,
                color: DubbingHomeTheme.subtitleGray,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
