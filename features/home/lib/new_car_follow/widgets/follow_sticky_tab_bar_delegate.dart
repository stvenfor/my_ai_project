import 'package:flutter/material.dart';

/// 悬浮置顶 TabBar（从成交页复制，避免依赖 module_settings）。
class FollowStickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  FollowStickyTabBarDelegate({
    required this.tabBar,
    this.backgroundColor = const Color(0xFFF5F6F8),
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
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant FollowStickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
