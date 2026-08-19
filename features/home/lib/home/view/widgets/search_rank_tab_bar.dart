import 'package:flutter/material.dart';
import 'package:module_home/home/model/search_page_model.dart';
import 'package:module_home/home/theme/search_page_theme.dart';

class SearchRankTabBar extends StatelessWidget {
  const SearchRankTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SearchPageTheme.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Row(
          children: List.generate(SearchRankTab.values.length, (index) {
            final active = index == selectedIndex;
            final tab = SearchRankTab.values[index];
            return Padding(
              padding: EdgeInsets.only(
                right: index < SearchRankTab.values.length - 1 ? 20 : 0,
              ),
              child: GestureDetector(
                onTap: () => onSelected(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: active ? 15 : 15,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active
                            ? SearchPageTheme.accent
                            : SearchPageTheme.labelSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: active ? 20 : 0,
                      height: 2,
                      color: SearchPageTheme.accent,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
