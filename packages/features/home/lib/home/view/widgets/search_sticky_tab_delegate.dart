import 'package:flutter/material.dart';
import 'package:module_home/home/theme/search_page_theme.dart';

/// 搜索页悬浮置顶 TabBar 的 Sliver 委托。
class SearchStickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  SearchStickyTabBarDelegate({
    required this.tabBar,
    this.backgroundColor = SearchPageTheme.background,
  });

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height + 0.5;

  @override
  double get maxExtent => tabBar.preferredSize.height + 0.5;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: SearchPageTheme.separator.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SearchStickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
