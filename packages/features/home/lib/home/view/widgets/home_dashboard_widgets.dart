import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/home_controller.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed<void>(RoutePath.homeSearch),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20.sp, color: Colors.white70),
                    SizedBox(width: 8.w),
                    Text(
                      '搜索客户、订单、资讯',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.qr_code_scanner_rounded, size: 22.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class HomeBannerSection extends StatelessWidget {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B5DAE), Color(0xFF1A3A6E)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B5DAE).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CacheImageUtils.network(
            'https://picsum.photos/seed/banner/800/400',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.35),
            colorBlendMode: BlendMode.darken,
            borderRadius: BorderRadius.circular(16.r),
          ),
          Positioned(
            left: 20.w,
            top: 28.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[功能] 朋友圈',
                  style: TextStyle(
                    color: Colors.white,
                  fontSize: 20.sp,
                    shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '一键分享，高效触达客户',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '立即体验',
                    style: TextStyle(
                      color: const Color(0xFF2B5DAE),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({super.key, required this.items});

  final List<HomeFeatureItem> items;

  void _onFeatureTap(HomeFeatureItem item) {
    if (item.label == '更多') {
      Get.toNamed(RoutePath.homeAllServices);
      return;
    }
    if (item.label == '生活服务') {
      Get.toNamed(RoutePath.homeCheckInMall);
      return;
    }
    if (item.label == '销售顾问') {
      final dashboard = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>().dashboard.value
          : null;
      Get.toNamed(
        RoutePath.web,
        arguments: WebPageConfig.asset(
          assetPath: WebBridgeAssets.testBridge,
          title: 'Web 桥接测试',
          params: {
            'from': 'home',
            'feature': item.label,
            'storeName': dashboard?.storeName ?? '',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.72,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => _onFeatureTap(item),
            child: Column(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: item.imageUrl != null
                      ? CacheImageUtils.network(
                          item.imageUrl!,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(14.r),
                          placeholder: (_, __) => Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.image_outlined,
                            size: 24.sp,
                            color: Colors.white60,
                          ),
                        )
                      : Center(
                          child: Text(
                            item.emoji ?? '?',
                            style: TextStyle(fontSize: 24.sp),
                          ),
                        ),
                ),
                SizedBox(height: 6.h),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HomeGreetingSection extends StatelessWidget {
  const HomeGreetingSection({
    super.key,
    required this.greeting,
  });

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              greeting,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: HomeDashboardTheme.titleBlack,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_rounded, size: 16.sp, color: const Color(0xFFFFB800)),
                SizedBox(width: 4.w),
                Text(
                  '3条新消息',
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFFFFB800), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeQuickActionGrid extends StatelessWidget {
  const HomeQuickActionGrid({super.key, required this.actions});

  final List<HomeQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.1,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: HomeDashboardTheme.cardWhite,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: HomeDashboardTheme.background,
                      ),
                      child: action.imageUrl != null
                          ? CacheImageUtils.network(
                              action.imageUrl!,
                              width: 40.w,
                              height: 40.w,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(10.r),
                              placeholder: (_, __) => Center(
                                child: SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(strokeWidth: 1.5),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Icon(
                                Icons.image_outlined,
                                size: 20.sp,
                                color: HomeDashboardTheme.textGray,
                              ),
                            )
                          : Center(
                              child: Text(action.emoji ?? '?', style: TextStyle(fontSize: 20.sp)),
                            ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            action.subtitle,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: HomeDashboardTheme.textGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: HomeDashboardTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        action.actionLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: HomeDashboardTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HomeStoreMetricsCard extends StatelessWidget {
  const HomeStoreMetricsCard({
    super.key,
    required this.storeName,
    required this.selectedTab,
    required this.tabs,
    required this.metrics,
    required this.details,
    required this.onTabSelected,
  });

  final String storeName;
  final int selectedTab;
  final List<String> tabs;
  final List<HomeMetric> metrics;
  final List<HomeMetricDetail> details;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: HomeDashboardTheme.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  storeName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, size: 22.sp),
              Icon(Icons.swap_horiz_rounded, size: 20.sp, color: HomeDashboardTheme.textGray),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(tabs.length, (index) {
              final active = index == selectedTab;
              return GestureDetector(
                onTap: () => onTabSelected(index),
                child: Container(
                  margin: EdgeInsets.only(right: 20.w),
                  child: Column(
                    children: [
                      Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                          color: active
                              ? HomeDashboardTheme.primaryBlue
                              : HomeDashboardTheme.textGray,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 24.w,
                        height: 2.h,
                        color: active ? HomeDashboardTheme.primaryBlue : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 2.2,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.value,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    metric.label,
                    style: TextStyle(fontSize: 12.sp, color: HomeDashboardTheme.textGray),
                  ),
                ],
              );
            },
          ),
          Divider(height: 24.h, color: HomeDashboardTheme.background),
          Row(
            children: details.map((detail) {
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      detail.value,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      detail.label,
                      style: TextStyle(fontSize: 11.sp, color: HomeDashboardTheme.textGray),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      detail.actionLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: HomeDashboardTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              '查看更多 >',
              style: TextStyle(fontSize: 13.sp, color: HomeDashboardTheme.textGray),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeServiceGrid extends StatelessWidget {
  const HomeServiceGrid({super.key, required this.items});

  final List<HomeServiceItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '服务推荐',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: HomeDashboardTheme.background,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: item.imageUrl != null
                            ? CacheImageUtils.network(
                                item.imageUrl!,
                                width: 48.w,
                                height: 48.w,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(14.r),
                                placeholder: (_, __) => Center(
                                  child: SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: const CircularProgressIndicator(strokeWidth: 1.5),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.image_outlined,
                                  size: 22.sp,
                                  color: HomeDashboardTheme.textGray,
                                ),
                              )
                            : Center(
                                child: Text(item.emoji ?? '?', style: TextStyle(fontSize: 24.sp)),
                              ),
                      ),
                      if (item.badge != null)
                        Positioned(
                          top: -2,
                          right: -4,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: item.badge == '热门'
                                  ? HomeDashboardTheme.badgeOrange
                                  : HomeDashboardTheme.badgeBlue,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              item.badge!,
                              style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    item.label,
                    style: TextStyle(fontSize: 12.sp, color: HomeDashboardTheme.textDarkGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class HomeContactList extends StatelessWidget {
  const HomeContactList({super.key, required this.items});

  final List<HomeContactItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '联系汽车之家',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: HomeDashboardTheme.cardWhite,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      leading: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: HomeDashboardTheme.background,
                        child: item.imageUrl != null
                            ? CacheImageUtils.circle(
                                item.imageUrl!,
                                size: 44.r,
                                placeholder: (_, __) => Center(
                                  child: SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: const CircularProgressIndicator(strokeWidth: 1.5),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Text(
                                  item.emoji ?? '?',
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                              )
                            : Text(item.emoji ?? '?', style: TextStyle(fontSize: 20.sp)),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: TextStyle(fontSize: 12.sp, color: HomeDashboardTheme.textGray),
                      ),
                      trailing: _trailingIcon(item.trailingType),
                    ),
                    if (index < items.length - 1)
                      Divider(height: 1, indent: 68.w, endIndent: 16.w, color: HomeDashboardTheme.background),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _trailingIcon(String? type) {
    return switch (type) {
      'chat' => Icon(Icons.chat_bubble_outline, color: HomeDashboardTheme.primaryBlue),
      'phone' => Icon(Icons.phone_outlined, color: HomeDashboardTheme.primaryBlue),
      null => Icon(Icons.chevron_right, color: HomeDashboardTheme.textGray),
      _ => Icon(Icons.chevron_right, color: HomeDashboardTheme.textGray),
    };
  }
}

class HomeNewsList extends StatelessWidget {
  const HomeNewsList({super.key, required this.items});

  final List<HomeNewsItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '行业动态',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.cardWhite,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${item.source}  ${item.date}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: HomeDashboardTheme.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: item.imageUrl != null
                          ? CacheImageUtils.network(
                              item.imageUrl!,
                              width: 96.w,
                              height: 72.h,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 96.w,
                                height: 72.h,
                                color: HomeDashboardTheme.background,
                                child: Center(
                                  child: SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: const CircularProgressIndicator(strokeWidth: 1.5),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 96.w,
                                height: 72.h,
                                color: HomeDashboardTheme.background,
                                child: Icon(Icons.directions_car_filled_outlined,
                                    color: HomeDashboardTheme.textGray, size: 28.sp),
                              ),
                            )
                          : Container(
                              width: 96.w,
                              height: 72.h,
                              decoration: BoxDecoration(
                                color: HomeDashboardTheme.background,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.directions_car_filled_outlined,
                                  color: HomeDashboardTheme.textGray, size: 28.sp),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
