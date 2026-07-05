import 'package:flutter/material.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeHotRankCard extends StatelessWidget {
  const DubbingHomeHotRankCard({
    super.key,
    required this.board,
    required this.onViewAll,
    required this.onItemTap,
  });

  final DubbingHomeHotRankBoard board;
  final VoidCallback onViewAll;
  final ValueChanged<DubbingHomeHotRankItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final previewItems = board.items.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DubbingHomeTheme.cardRadius.r),
        boxShadow: [
          BoxShadow(
            color: DubbingHomeTheme.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
            decoration: BoxDecoration(
              gradient: board.theme.headerGradient,
            ),
            child: Row(
              children: [
                Image.asset(
                  DubbingHomeAssets.path('wheat_left.png'),
                  package: DubbingHomeAssets.package,
                  width: 12.w,
                  height: 16.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    board.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: DubbingHomeTheme.titleBlack,
                    ),
                  ),
                ),
                Text(
                  'TOP 10',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: DubbingHomeTheme.subtitleGray,
                  ),
                ),
                SizedBox(width: 4.w),
                Image.asset(
                  DubbingHomeAssets.path('wheat_right.png'),
                  package: DubbingHomeAssets.package,
                  width: 12.w,
                  height: 16.h,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: board.theme.bodyGradient,
            ),
            child: Column(
              children: [
                for (var i = 0; i < previewItems.length; i++)
                  _RankPreviewRow(
                    item: previewItems[i],
                    showDivider: i > 0,
                    onTap: () => onItemTap(previewItems[i]),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 11.h),
              decoration: const BoxDecoration(
                color: DubbingHomeTheme.viewAllBackground,
                border: Border(
                  top: BorderSide(color: DubbingHomeTheme.divider, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '查看全部',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DubbingHomeTheme.subtitleGray,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Image.asset(
                    DubbingHomeAssets.path('icon_chevron_right.png'),
                    package: DubbingHomeAssets.package,
                    width: 10.w,
                    height: 10.w,
                    fit: BoxFit.contain,
                    color: DubbingHomeTheme.subtitleGray,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankPreviewRow extends StatelessWidget {
  const _RankPreviewRow({
    required this.item,
    required this.showDivider,
    required this.onTap,
  });

  final DubbingHomeHotRankItem item;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: const Divider(height: 1, color: DubbingHomeTheme.divider),
          ),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Image.asset(
                        DubbingHomeAssets.path(item.coverAsset),
                        package: DubbingHomeAssets.package,
                        width: 44.w,
                        height: 44.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (item.rank <= 3)
                      Positioned(
                        left: -3.w,
                        top: -5.h,
                        child: Image.asset(
                          DubbingHomeAssets.rankBadgeAsset(item.rank),
                          package: DubbingHomeAssets.package,
                          width: 16.w,
                          height: 18.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: DubbingHomeTheme.titleBlack,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: DubbingHomeTheme.subtitleGray,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '热度 ${item.heat}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: DubbingHomeTheme.subtitleGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
