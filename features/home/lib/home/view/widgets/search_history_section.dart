import 'package:flutter/cupertino.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_tag_chip.dart';
import 'package:module_utils/module_utils.dart';

class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    super.key,
    required this.history,
    required this.onClear,
    required this.onTagTap,
  });

  final List<String> history;
  final VoidCallback onClear;
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
              Text('搜索历史', style: SearchPageTheme.sectionTitle),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onClear,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.trash,
                      size: 16.sp,
                      color: SearchPageTheme.labelSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '清除',
                      style: SearchPageTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final tag in history)
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
