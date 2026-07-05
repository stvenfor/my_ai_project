import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/hot_rank_detail_controller.dart';
import 'package:module_home/home/model/hot_rank_detail_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_home/home/view/widgets/hot_rank/hot_rank_age_filter.dart';
import 'package:module_home/home/view/widgets/hot_rank/hot_rank_list_item.dart';
import 'package:module_home/home/view/widgets/hot_rank/hot_rank_sidebar.dart';

class HotRankDetailPage extends GetView<HotRankDetailController> {
  const HotRankDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HotRankDetailController>()) {
      HotRankDetailBinding().dependencies();
    }

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: DubbingHomeTheme.background,
      body: Obx(() {
        final pageState = controller.state.value;
        if (pageState == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = pageState.currentItems.toList();

        return GestureDetector(
          onTap: controller.closeAgeFilterMenu,
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: [
              _HotRankHeader(pageState: pageState),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const HotRankSidebar(),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: DubbingHomeTheme.background,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 4.h),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: const HotRankAgeFilterBar(),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.only(bottom: 24.h),
                                itemCount: items.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  indent: 12.w,
                                  endIndent: 12.w,
                                  color: DubbingHomeTheme.divider,
                                ),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return HotRankListItem(
                                    item: item,
                                    onTap: () => controller.onItemTap(item),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _HotRankHeader extends StatelessWidget {
  const _HotRankHeader({required this.pageState});

  final HotRankDetailState pageState;

  @override
  Widget build(BuildContext context) {
    final top = AppSafeInsets.top(context);

    return Container(
      padding: EdgeInsets.fromLTRB(8.w, top + 4.h, 8.w, 16.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DubbingHomeTheme.hotRankHeaderPink,
            Colors.white,
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back<void>(),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 44.w,
                  height: 44.w,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20.sp,
                    color: DubbingHomeTheme.titleBlack,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 44.w,
                  height: 44.w,
                  child: Image.asset(
                    HotRankDetailAssets.path('icon_share.png'),
                    package: HotRankDetailAssets.package,
                    width: 22.w,
                    height: 22.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                HotRankDetailAssets.path('wheat_large_left.png'),
                package: HotRankDetailAssets.package,
                width: 28.w,
                height: 36.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
              Text(
                pageState.title,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: DubbingHomeTheme.titleBlack,
                ),
              ),
              SizedBox(width: 8.w),
              Image.asset(
                HotRankDetailAssets.path('wheat_large_right.png'),
                package: HotRankDetailAssets.package,
                width: 28.w,
                height: 36.h,
                fit: BoxFit.contain,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            pageState.subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: DubbingHomeTheme.subtitleGray,
            ),
          ),
        ],
      ),
    );
  }
}
