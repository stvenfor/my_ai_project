import 'package:flutter/material.dart';
import 'package:module_settings/mine/model/mine_function_item.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';

class MineFunctionCardWidget extends StatelessWidget {
  const MineFunctionCardWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MineFunctionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MineTheme.surface,
      borderRadius: BorderRadius.circular(MineTheme.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: MineTheme.separator, width: 0.5),
            borderRadius: BorderRadius.circular(MineTheme.radiusMd),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 24, color: item.iconColor),
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MineTheme.headline.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MineTheme.caption.copyWith(fontSize: 12),
              ),
              if (item.id == 'calculator') ...[
                const SizedBox(height: 8),
                Text(
                  '5830.00',
                  style: MineTheme.statValue.copyWith(
                    fontSize: 16,
                    color: item.iconColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
