import 'package:flutter/material.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_utils/module_utils.dart';

enum DubbingSectionHeaderStyle {
  chevron,
  refresh,
  none,
}

class DubbingHomeSectionHeader extends StatelessWidget {
  const DubbingHomeSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.style = DubbingSectionHeaderStyle.none,
    this.onTrailingTap,
  });

  final String title;
  final String? subtitle;
  final DubbingSectionHeaderStyle style;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: DubbingHomeTheme.sectionTitleSize.sp,
                    fontWeight: FontWeight.w600,
                    color: DubbingHomeTheme.titleBlack,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DubbingHomeTheme.subtitleGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (style == DubbingSectionHeaderStyle.chevron)
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Image.asset(
                  DubbingHomeAssets.path('icon_chevron_right.png'),
                  package: DubbingHomeAssets.package,
                  width: 16.w,
                  height: 16.w,
                  fit: BoxFit.contain,
                ),
              ),
            )
          else if (style == DubbingSectionHeaderStyle.refresh)
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      DubbingHomeAssets.path('icon_swap.png'),
                      package: DubbingHomeAssets.package,
                      width: 14.w,
                      height: 14.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '换一换',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: DubbingHomeTheme.subtitleGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
