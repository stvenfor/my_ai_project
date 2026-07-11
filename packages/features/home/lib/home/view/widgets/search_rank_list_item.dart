import 'package:flutter/material.dart';
import 'package:module_home/home/model/search_page_model.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_utils/module_utils.dart';

class SearchRankListItem extends StatelessWidget {
  const SearchRankListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.showDivider = true,
  });

  final SearchRankItem item;
  final VoidCallback onTap;
  final bool showDivider;

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RankIndicator(rank: item.rank, color: rankColor),
                  SizedBox(width: 12.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: CacheImageUtils.network(
                      item.coverUrl,
                      width: 72.w,
                      height: 72.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 72.w,
                        height: 72.w,
                        color: SearchPageTheme.fillSecondary,
                        child: Icon(
                          Icons.play_circle_outline,
                          color: SearchPageTheme.labelTertiary,
                          size: 28.sp,
                        ),
                      ),
                    ),
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
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: SearchPageTheme.labelPrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: SearchPageTheme.caption.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: SearchPageTheme.labelTertiary,
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 0.5,
                indent: 52.w,
                endIndent: 16.w,
                color: SearchPageTheme.separator,
              ),
          ],
        ),
      ),
    );
  }
}

class _RankIndicator extends StatelessWidget {
  const _RankIndicator({required this.rank, this.color});

  final int rank;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (color != null) {
      return Container(
        width: 24.w,
        alignment: Alignment.center,
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );
    }

    return SizedBox(
      width: 24.w,
      child: Text(
        '$rank',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: SearchPageTheme.labelSecondary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
