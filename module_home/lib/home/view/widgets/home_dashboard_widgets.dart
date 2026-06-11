import 'package:flutter/material.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_utils/module_utils.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: HomeDashboardTheme.cardWhite,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20.sp, color: HomeDashboardTheme.textGray),
                  SizedBox(width: 8.w),
                  Text(
                    '搜索客户、订单、资讯',
                    style: TextStyle(fontSize: 14.sp, color: HomeDashboardTheme.textGray),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Icon(Icons.qr_code_scanner_rounded, size: 24.sp, color: HomeDashboardTheme.titleBlack),
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
      height: 120.h,
      decoration: BoxDecoration(
        color: HomeDashboardTheme.bannerDark,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20.w,
            top: 24.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[功能] 朋友圈',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: HomeDashboardTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    '立即体验',
                    style: TextStyle(color: Colors.white, fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16.w,
            bottom: 0,
            child: Icon(Icons.person, size: 80.sp, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({super.key, required this.items});

  final List<HomeFeatureItem> items;

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
          childAspectRatio: 0.75,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Column(
            children: [
              Text(item.emoji, style: TextStyle(fontSize: 28.sp)),
              SizedBox(height: 6.h),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.sp, color: Colors.white70),
              ),
            ],
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
    required this.onRefresh,
  });

  final String greeting;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              greeting,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: HomeDashboardTheme.titleBlack,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh_rounded, size: 22.sp),
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
          childAspectRatio: 1.6,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: HomeDashboardTheme.cardWhite,
              borderRadius: BorderRadius.circular(12.r),
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
                Text(action.emoji, style: TextStyle(fontSize: 22.sp)),
                SizedBox(height: 8.h),
                Text(
                  action.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  action.subtitle,
                  style: TextStyle(fontSize: 11.sp, color: HomeDashboardTheme.textGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  action.actionLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: HomeDashboardTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
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
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: HomeDashboardTheme.cardWhite,
        borderRadius: BorderRadius.circular(12.r),
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
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '服务推荐',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(item.emoji, style: TextStyle(fontSize: 32.sp)),
                      if (item.badge != null)
                        Positioned(
                          top: -4,
                          right: -8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: item.badge == '热门'
                                  ? HomeDashboardTheme.badgeOrange
                                  : HomeDashboardTheme.badgeBlue,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              item.badge!,
                              style: TextStyle(color: Colors.white, fontSize: 8.sp),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.label,
                    style: TextStyle(fontSize: 12.sp),
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
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '联系汽车之家',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          ...items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: HomeDashboardTheme.background,
                child: Text(item.emoji ?? '?', style: TextStyle(fontSize: 20.sp)),
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
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '行业动态',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
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
                  Container(
                    width: 96.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: HomeDashboardTheme.background,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(Icons.directions_car_filled_outlined,
                        color: HomeDashboardTheme.textGray, size: 32.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
