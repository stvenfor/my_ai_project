import 'package:flutter/cupertino.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_tag_chip.dart';
import 'package:module_utils/module_utils.dart';

class SearchFilterSection extends StatelessWidget {
  const SearchFilterSection({
    super.key,
    required this.tags,
    required this.onTagTap,
  });

  final List<String> tags;
  final ValueChanged<String> onTagTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('快捷筛选', style: SearchPageTheme.sectionTitle),
              SizedBox(width: 6.w),
              Icon(
                CupertinoIcons.slider_horizontal_3,
                size: 18.sp,
                color: SearchPageTheme.accent,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final tag in tags)
                SearchTagChip(
                  label: tag,
                  onTap: () => onTagTap(tag),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
