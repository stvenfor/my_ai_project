import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:module_common_ui/theme/vercel_tokens.dart';

class IosTabBarItem {
  const IosTabBarItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// 底部 TabBar：毛玻璃背景 + Token API 选中态（link）。
class IosTabBar extends StatelessWidget {
  const IosTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<IosTabBarItem> items;

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.tabBarBackground,
            border: Border(
              top: BorderSide(
                color: tokens.hairline.withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 49,
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final selected = index == selectedIndex;
                  return Expanded(
                    child: _TabItem(
                      label: item.label,
                      icon: selected ? item.selectedIcon : item.icon,
                      selected: selected,
                      onTap: () => onTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    final color = selected ? tokens.link : tokens.mute;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 44,
              height: 28,
              alignment: Alignment.center,
              decoration: selected
                  ? BoxDecoration(
                      color: tokens.link.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    )
                  : null,
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
