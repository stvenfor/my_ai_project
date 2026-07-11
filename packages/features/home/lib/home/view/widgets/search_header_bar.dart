import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/search_controller.dart';
import 'package:module_home/home/mock/search_mock_data.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_home/home/view/widgets/search_rotating_keyword.dart';
import 'package:module_utils/module_utils.dart';

class SearchHeaderBar extends GetView<HomeSearchController> {
  const SearchHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 44.w,
            height: 44.w,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: controller.onBack,
              child: Icon(
                CupertinoIcons.back,
                size: 24.sp,
                color: SearchPageTheme.accent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: SearchPageTheme.searchFieldHeight.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: SearchPageTheme.surface,
                borderRadius: BorderRadius.circular(SearchPageTheme.radiusMd.r),
                border: Border.all(
                  color: SearchPageTheme.separator,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: controller.submitCurrentKeyword,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      CupertinoIcons.search,
                      size: 18.sp,
                      color: SearchPageTheme.labelSecondary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        TextField(
                          controller: controller.keywordController,
                          focusNode: controller.searchFocusNode,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: SearchPageTheme.labelPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: SearchMockData.searchPlaceholder,
                            hintStyle: TextStyle(
                              fontSize: 15.sp,
                              color: SearchPageTheme.labelTertiary,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => controller.onSearchSubmit(),
                        ),
                        Obx(() {
                          if (!controller.showRotatingOverlay.value) {
                            return const SizedBox.shrink();
                          }
                          controller.rotateIndex.value;
                          final keyword = controller.currentRotatingKeyword;
                          if (keyword.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Positioned.fill(
                            child: IgnorePointer(
                              child: ColoredBox(
                                color: SearchPageTheme.surface,
                                child: SearchRotatingKeyword(keyword: keyword),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: controller.keywordController,
                    builder: (context, _) {
                      final hasText =
                          controller.keywordController.text.isNotEmpty;
                      if (hasText) {
                        return GestureDetector(
                          onTap: controller.clearKeyword,
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 18.sp,
                            color: SearchPageTheme.labelTertiary,
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: controller.onVoiceTap,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Icon(
                            CupertinoIcons.mic,
                            size: 20.sp,
                            color: SearchPageTheme.accent,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            onPressed: controller.onCancel,
            child: Text(
              '取消',
              style: TextStyle(
                fontSize: 16.sp,
                color: SearchPageTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
