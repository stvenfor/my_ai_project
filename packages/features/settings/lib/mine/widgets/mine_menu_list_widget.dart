import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_settings/mine/model/mine_menu_data.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';

class MineMenuListWidget extends StatelessWidget {
  const MineMenuListWidget({
    super.key,
    required this.onTap,
  });

  final ValueChanged<MineMenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: DecoratedBox(
        decoration: MineTheme.groupedCardDecoration,
        child: Column(
          children: MineMenuData.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: item.destructive
                                ? const Color(0xFFFF3B30)
                                : MineTheme.accent,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.label,
                              style: MineTheme.body.copyWith(
                                color: item.destructive
                                    ? const Color(0xFFFF3B30)
                                    : MineTheme.labelPrimary,
                              ),
                            ),
                          ),
                          if (item.showBadge)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                            ),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: MineTheme.labelTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (index < MineMenuData.items.length - 1)
                  Divider(
                    height: 0.5,
                    indent: 52,
                    color: MineTheme.separator,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
