import 'package:flutter/cupertino.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_tag_chip.dart';
import 'package:module_utils/module_utils.dart';

class SearchDiscoverySection extends StatelessWidget {
  const SearchDiscoverySection({
    super.key,
    required this.discovery,
    required this.onRefresh,
    required this.onTagTap,
  });

  final List<String> discovery;
  final VoidCallback onRefresh;
  final ValueChanged<String> onTagTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: DecoratedBox(
        decoration: SearchPageTheme.groupedCardDecoration,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('搜索发现', style: SearchPageTheme.sectionTitle),
                  SizedBox(width: 6.w),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onRefresh,
                    child: Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      size: 18.sp,
                      color: SearchPageTheme.accent,
                    ),
                  ),
                  const Spacer(),
                  Text('换一换', style: SearchPageTheme.caption),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (var i = 0; i < discovery.length; i++)
                    SearchTagChip(
                      label: discovery[i],
                      highlight: i == 0,
                      onTap: () => onTagTap(discovery[i]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
