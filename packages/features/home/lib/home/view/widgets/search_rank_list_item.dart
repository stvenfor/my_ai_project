import 'package:flutter/material.dart';
import 'package:module_home/home/model/search_page_model.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_utils/module_utils.dart';

class SearchRankListItem extends StatelessWidget {
  const SearchRankListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final SearchRankItem item;
  final VoidCallback onTap;

  Color? _rankColor() {
    switch (item.rank) {
      case 1:
        return SearchPageTheme.rankGold;
      case 2:
        return SearchPageTheme.rankSilver;
      case 3:
        return SearchPageTheme.rankBronze;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    item.coverUrl,
                    width: 72.w,
                    height: 72.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72.w,
                      height: 72.w,
                      color: SearchPageTheme.tagBackground,
                      child: Icon(
                        Icons.image_outlined,
                        color: SearchPageTheme.subtitleGray,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
                if (rankColor != null)
                  Positioned(
                    left: -2.w,
                    top: -2.h,
                    child: _RankBadge(
                      rank: item.rank,
                      color: rankColor,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: SearchPageTheme.titleBlack,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: SearchPageTheme.subtitleGray,
                      height: 1.4,
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

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.color,
  });

  final int rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.w,
      height: 22.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            SearchAssets.path('rank_badge_bg.png'),
            package: SearchAssets.package,
            width: 20.w,
            height: 22.h,
            fit: BoxFit.fill,
            color: color,
            colorBlendMode: BlendMode.srcIn,
          ),
          Text(
            '$rank',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
