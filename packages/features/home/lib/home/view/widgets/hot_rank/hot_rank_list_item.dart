import 'package:flutter/material.dart';
import 'package:module_home/home/model/hot_rank_detail_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class HotRankListItem extends StatelessWidget {
  const HotRankListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final HotRankDetailItem item;
  final VoidCallback onTap;

  Color _rankBgColor() {
    switch (item.rank) {
      case 1:
        return DubbingHomeTheme.hotRankRankGold;
      case 2:
        return DubbingHomeTheme.hotRankRankSilver;
      case 3:
        return DubbingHomeTheme.hotRankRankBronze;
      default:
        return DubbingHomeTheme.hotRankRankDefault;
    }
  }

  Color _rankTextColor() {
    return item.rank <= 3 ? Colors.white : DubbingHomeTheme.textGray;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                DubbingHomeAssets.path(item.coverAsset),
                package: DubbingHomeAssets.package,
                width: 56.w,
                height: 56.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 18.w,
              height: 18.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _rankBgColor(),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${item.rank}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: _rankTextColor(),
                  height: 1,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: DubbingHomeTheme.titleBlack,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DubbingHomeTheme.subtitleGray,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '热度${item.heat}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: DubbingHomeTheme.subtitleGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
