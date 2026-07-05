import 'package:flutter/material.dart';

/// 搜索页悬浮置顶 TabBar 的 Sliver 委托。
class SearchStickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  SearchStickyTabBarDelegate({
    required this.tabBar,
    this.backgroundColor = Colors.white,
  });

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SearchStickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
