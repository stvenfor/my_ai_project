import 'package:flutter/material.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_utils/module_utils.dart';

class SearchTagChip extends StatelessWidget {
  const SearchTagChip({
    super.key,
    required this.label,
    required this.onTap,
    this.expand = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: SearchPageTheme.tagBackground,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.sp,
            color: SearchPageTheme.tagText,
          ),
        ),
      ),
    );
  }
}
