import 'package:flutter/material.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_utils/module_utils.dart';

class SearchTagChip extends StatelessWidget {
  const SearchTagChip({
    super.key,
    required this.label,
    required this.onTap,
    this.expand = false,
    this.highlight = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool expand;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bgColor = highlight
        ? SearchPageTheme.accent.withValues(alpha: 0.1)
        : SearchPageTheme.fillSecondary;
    final textColor = highlight
        ? SearchPageTheme.accent
        : SearchPageTheme.labelPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: expand ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 14.sp,
            color: textColor,
            fontWeight: highlight ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
