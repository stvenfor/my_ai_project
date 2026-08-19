import 'package:flutter/material.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_utils/module_utils.dart';

/// 搜索框内历史词上下翻动轮播。
class SearchRotatingKeyword extends StatelessWidget {
  const SearchRotatingKeyword({
    super.key,
    required this.keyword,
  });

  final String keyword;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation);
          return ClipRect(
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.hardEdge,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: Text(
          keyword,
          key: ValueKey<String>(keyword),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.sp,
            color: SearchPageTheme.labelPrimary,
          ),
        ),
      ),
    );
  }
}
