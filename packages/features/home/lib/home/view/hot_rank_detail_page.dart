import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_route/route/route_path.dart';

class HotRankDetailPage extends StatelessWidget {
  const HotRankDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final board = Get.arguments as DubbingHomeHotRankBoard?;

    if (board == null) {
      return AppPageScaffold(
        layout: AppPageLayout.edgeToEdge,
        backgroundColor: DubbingHomeTheme.background,
        body: const Center(child: Text('榜单数据不存在')),
      );
    }

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: DubbingHomeTheme.background,
      body: Column(
        children: [
          AppNavBar(
            title: '${board.title} TOP 10',
            showBackButton: true,
            onBack: () => Get.back<void>(),
            backgroundColor: board.theme.top,
            foregroundColor: DubbingHomeTheme.titleBlack,
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              itemCount: board.items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = board.items[index];
                return _HotRankDetailRow(
                  item: item,
                  theme: board.theme,
                  onTap: () {
                    Get.toNamed<void>(
                      RoutePath.dubbingVideoDetail,
                      arguments: {'id': item.id},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HotRankDetailRow extends StatelessWidget {
  const _HotRankDetailRow({
    required this.item,
    required this.theme,
    required this.onTap,
  });

  final DubbingHomeHotRankItem item;
  final HotRankCardTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: DubbingHomeTheme.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    DubbingHomeAssets.path(item.coverAsset),
                    package: DubbingHomeAssets.package,
                    width: 72.w,
                    height: 72.w,
                    fit: BoxFit.cover,
                  ),
                ),
                if (item.rank <= 3)
                  Positioned(
                    left: -4.w,
                    top: -4.h,
                    child: Image.asset(
                      DubbingHomeAssets.rankBadgeAsset(item.rank),
                      package: DubbingHomeAssets.package,
                      width: 22.w,
                      height: 24.h,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Positioned(
                    left: -4.w,
                    top: -4.h,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.bottom,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${item.rank}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: DubbingHomeTheme.titleBlack,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: DubbingHomeTheme.titleBlack,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: DubbingHomeTheme.subtitleGray,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '热度 ${item.heat}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DubbingHomeTheme.subtitleGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
