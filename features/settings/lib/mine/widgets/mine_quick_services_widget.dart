import 'package:flutter/material.dart';
import 'package:module_settings/mine/model/mine_menu_data.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';

class MineQuickServicesWidget extends StatelessWidget {
  const MineQuickServicesWidget({
    super.key,
    required this.onTap,
  });

  final ValueChanged<MineQuickServiceItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('常用服务', style: MineTheme.headline.copyWith(fontSize: 17)),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: MineTheme.groupedCardDecoration,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Row(
                children: MineQuickServiceData.items
                    .map(
                      (item) => Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(item),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: item.iconColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 22,
                                      color: item.iconColor,
                                    ),
                                  ),
                                  if (item.badge != null)
                                    Positioned(
                                      top: -6,
                                      right: -8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF3B30),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.badge!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.label,
                                style: MineTheme.caption.copyWith(
                                  color: MineTheme.labelPrimary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
