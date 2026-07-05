import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/search_controller.dart';
import 'package:module_home/home/mock/search_mock_data.dart';
import 'package:module_home/home/theme/search_page_theme.dart';
import 'package:module_utils/module_utils.dart';

class SearchHeaderBar extends GetView<HomeSearchController> {
  const SearchHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: controller.onBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
              color: SearchPageTheme.titleBlack,
            ),
            padding: EdgeInsets.all(8.w),
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
          ),
          Expanded(
            child: Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: SearchPageTheme.searchFieldBackground,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 18.sp,
                    color: SearchPageTheme.subtitleGray,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: TextField(
                      controller: controller.keywordController,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: SearchPageTheme.titleBlack,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: SearchMockData.defaultKeyword,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: SearchPageTheme.subtitleGray,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.onVoiceTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Image.asset(
                        SearchAssets.path('microphone.png'),
                        package: SearchAssets.package,
                        width: 18.w,
                        height: 18.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: controller.onCancel,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: SearchPageTheme.titleBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
