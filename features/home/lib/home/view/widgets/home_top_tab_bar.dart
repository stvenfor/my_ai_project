import 'package:flutter/material.dart';
import 'package:module_home/home/controller/home_controller.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';

class HomeTopTabBar extends StatelessWidget {
  const HomeTopTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: List.generate(HomeController.topTabs.length, (index) {
          final active = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index < HomeController.topTabs.length - 1 ? 24 : 0,
            ),
            child: GestureDetector(
              onTap: () => onSelected(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Text(
                    HomeController.topTabs[index],
                    style: TextStyle(
                      fontSize: active ? 17 : 16,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active
                          ? HomeDashboardTheme.labelPrimary
                          : HomeDashboardTheme.labelSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: active ? 20 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: HomeDashboardTheme.accent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
