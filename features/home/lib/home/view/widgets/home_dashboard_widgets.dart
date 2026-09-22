import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/home_controller.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';
import 'package:module_home/home/model/home_todo_models.dart';
import 'package:module_home/home/model/home_todo_packer.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_home/home/navigation/ai_stone_navigation.dart';
import 'package:module_home/home/navigation/analytics_navigation.dart';
import 'package:module_home/home/navigation/used_car_navigation.dart';
import 'package:wys_router/src/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed<void>(RoutePath.homeSearch),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.surface,
                  borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
                  border: Border.all(
                    color: HomeDashboardTheme.separator,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 20.sp,
                      color: HomeDashboardTheme.labelSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '搜索客户、订单、资讯',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: HomeDashboardTheme.labelTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Material(
            color: HomeDashboardTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
              side: const BorderSide(
                color: HomeDashboardTheme.separator,
                width: 0.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
              onTap: () async {
                final result = await ScanUtils.scanWithCamera(context);
                if (result == null || result.isEmpty) return;
                UiKitInitializer.toast(result);
              },
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 22.sp,
                  color: HomeDashboardTheme.accent,
                ),
              ),
            ),
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
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      height: 132.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        color: HomeDashboardTheme.surface,
        boxShadow: HomeDashboardTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CacheImageUtils.network(
            'https://picsum.photos/seed/banner/800/400',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.25),
            colorBlendMode: BlendMode.darken,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  HomeDashboardTheme.accent.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            top: 24.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '朋友圈营销',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '一键分享，高效触达客户',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '立即体验',
                    style: TextStyle(
                      color: HomeDashboardTheme.accent,
                      fontSize: 14.sp,
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
      Get.toNamed(RoutePath.homeLifeService);
      return;
    }
    if (item.label == '直播带货') {
      Get.toNamed(RoutePath.homeLiveCommerce);
      return;
    }
    if (item.label == 'Club') {
      Get.toNamed(RoutePath.homeClub);
      return;
    }
    if (item.label == '二手车') {
      UsedCarNavigation.open();
      return;
    }
    if (item.label == 'AI小石头') {
      AiStoneNavigation.open();
      return;
    }
    if (item.label == '数据分析') {
      AnalyticsNavigation.open();
      return;
    }
    if (item.label == 'H5 调试') {
      final dashboard = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>().dashboard.value
          : null;
      Get.toNamed(
        RoutePath.web,
        arguments: WebPageConfig.asset(
          assetPath: WebBridgeAssets.testBridge,
          title: 'H5 调试',
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
    const maxItems = 10; // 5 列 × 最多 2 行
    const crossAxisCount = 5;
    final iconSize = 44.w;
    final labelGap = 4.h;
    final labelStyle = TextStyle(
      fontSize: 11.sp,
      height: 1.2,
      color: HomeDashboardTheme.labelPrimary,
    );
    final visible =
        items.length > maxItems ? items.sublist(0, maxItems) : items;
    final rows = <List<HomeFeatureItem>>[];
    for (var i = 0; i < visible.length; i += crossAxisCount) {
      final end = i + crossAxisCount > visible.length
          ? visible.length
          : i + crossAxisCount;
      rows.add(visible.sublist(i, end));
    }

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 8.h),
      decoration: HomeDashboardTheme.groupedCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in rows[r])
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onFeatureTap(item),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: HomeDashboardTheme.fillSecondary,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: item.imageUrl != null
                                ? CacheImageUtils.network(
                                    item.imageUrl!,
                                    width: iconSize,
                                    height: iconSize,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(12.r),
                                    placeholder: (_, __) => Center(
                                      child: SizedBox(
                                        width: 18.w,
                                        height: 18.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Icon(
                                      Icons.apps_rounded,
                                      size: 22.sp,
                                      color: HomeDashboardTheme.accent,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      item.emoji ?? '?',
                                      style: TextStyle(fontSize: 22.sp),
                                    ),
                                  ),
                          ),
                          SizedBox(height: labelGap),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: labelStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                for (var j = rows[r].length; j < crossAxisCount; j++)
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ],
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
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              greeting,
              style: HomeDashboardTheme.largeTitle.copyWith(fontSize: 28.sp),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: HomeDashboardTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 16.sp,
                  color: HomeDashboardTheme.accent,
                ),
                SizedBox(width: 4.w),
                Text(
                  '3条新消息',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: HomeDashboardTheme.accent,
                    fontWeight: FontWeight.w500,
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

class HomeTodoCardStrip extends StatelessWidget {
  const HomeTodoCardStrip({super.key, required this.cards});

  final List<HomeTodoCard> cards;

  static String resolveRoute(HomeTodoCard card) {
    if (card.actionRoute.isNotEmpty) return card.actionRoute;
    switch (card.type) {
      case 'partner_pending':
        return RoutePath.homeTodoPartnerPending;
      case 'follow_up_customer':
        return RoutePath.homeTodoFollowUp;
      case 'after_sales_appointment':
        return RoutePath.homeTodoAfterSales;
      case 'order_pending_review':
        return RoutePath.homeTodoOrderReview;
      default:
        return RoutePath.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    void open(HomeTodoCard card) {
      Get.toNamed<void>(resolveRoute(card));
    }

    if (HomeTodoPacker.shouldWrapOnly(cards)) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(width: 12.w),
              Expanded(
                child: _HomeTodoCardView(card: cards[i], onTap: () => open(cards[i])),
              ),
            ],
            for (var i = cards.length; i < 2; i++) ...[
              SizedBox(width: 12.w),
              const Expanded(child: SizedBox.shrink()),
            ],
          ],
        ),
      );
    }

    final pages = HomeTodoPacker.packPages(cards);
    final height = 132.h;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: SizedBox(
        height: height,
        child: PageView.builder(
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return _TodoPageGrid(page: pages[index], onOpen: open);
          },
        ),
      ),
    );
  }
}

class _TodoPageGrid extends StatelessWidget {
  const _TodoPageGrid({required this.page, required this.onOpen});

  final List<HomeTodoCard> page;
  final void Function(HomeTodoCard) onOpen;

  @override
  Widget build(BuildContext context) {
    // 按行布局：中/大卡整行；小卡两列。
    final rows = <List<HomeTodoCard>>[];
    var i = 0;
    while (i < page.length) {
      final card = page[i];
      if (card.size == HomeTodoSize.large || card.size == HomeTodoSize.medium) {
        rows.add([card]);
        i++;
        continue;
      }
      final row = <HomeTodoCard>[card];
      i++;
      if (i < page.length && page[i].size == HomeTodoSize.small) {
        row.add(page[i]);
        i++;
      }
      rows.add(row);
    }

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: 12.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) SizedBox(width: 12.w),
                  Expanded(
                    flex: rows[r][c].size == HomeTodoSize.small && rows[r].length == 1
                        ? 1
                        : (rows[r][c].size == HomeTodoSize.small ? 1 : 2),
                    child: _HomeTodoCardView(
                      card: rows[r][c],
                      onTap: () => onOpen(rows[r][c]),
                    ),
                  ),
                ],
                if (rows[r].length == 1 && rows[r].first.size == HomeTodoSize.small) ...[
                  SizedBox(width: 12.w),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HomeTodoCardView extends StatelessWidget {
  const _HomeTodoCardView({required this.card, required this.onTap});

  final HomeTodoCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeDashboardTheme.surface,
      borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
            border: Border.all(
              color: HomeDashboardTheme.separator,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    child: card.imageUrl != null
                        ? CacheImageUtils.network(
                            card.imageUrl!,
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
                            child: Icon(
                              Icons.assignment_outlined,
                              size: 20.sp,
                              color: HomeDashboardTheme.textGray,
                            ),
                          ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          card.subtitle,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: HomeDashboardTheme.textGray,
                          ),
                          maxLines: card.size == HomeTodoSize.large ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: HomeDashboardTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    card.actionLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: HomeDashboardTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        border: Border.all(
          color: HomeDashboardTheme.separator,
          width: 0.5,
        ),
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
            style: HomeDashboardTheme.sectionTitle.copyWith(fontSize: 20.sp),
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
          Text('联系汽车之家', style: HomeDashboardTheme.sectionTitle),
          SizedBox(height: 12.h),
          DecoratedBox(
            decoration: BoxDecoration(
              color: HomeDashboardTheme.surface,
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
              border: Border.all(
                color: HomeDashboardTheme.separator,
                width: 0.5,
              ),
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
                        backgroundColor: HomeDashboardTheme.fillSecondary,
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
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.person_outline,
                                  size: 20.sp,
                                  color: HomeDashboardTheme.accent,
                                ),
                              )
                            : Icon(
                                Icons.person_outline,
                                size: 20.sp,
                                color: HomeDashboardTheme.accent,
                              ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: HomeDashboardTheme.labelPrimary,
                        ),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: HomeDashboardTheme.sectionLabel,
                      ),
                      trailing: _trailingIcon(item.trailingType),
                    ),
                    if (index < items.length - 1)
                      Divider(
                        height: 0.5,
                        indent: 68.w,
                        endIndent: 16.w,
                        color: HomeDashboardTheme.separator,
                      ),
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
      'chat' => Icon(Icons.chat_bubble_outline, color: HomeDashboardTheme.accent, size: 20.sp),
      'phone' => Icon(Icons.phone_outlined, color: HomeDashboardTheme.accent, size: 20.sp),
      null => Icon(Icons.chevron_right, color: HomeDashboardTheme.labelTertiary, size: 20.sp),
      _ => Icon(Icons.chevron_right, color: HomeDashboardTheme.labelTertiary, size: 20.sp),
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
          Row(
            children: [
              Expanded(
                child: Text('行业动态', style: HomeDashboardTheme.sectionTitle),
              ),
              Text(
                '查看更多',
                style: HomeDashboardTheme.sectionLabel.copyWith(
                  color: HomeDashboardTheme.accent,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: HomeDashboardTheme.accent,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.surface,
                  borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
                  border: Border.all(
                    color: HomeDashboardTheme.separator,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
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
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: HomeDashboardTheme.labelPrimary,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${item.source}  ${item.date}',
                              style: HomeDashboardTheme.sectionLabel,
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
                                  color: HomeDashboardTheme.fillSecondary,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 96.w,
                                  height: 72.h,
                                  color: HomeDashboardTheme.fillSecondary,
                                  child: Icon(
                                    Icons.article_outlined,
                                    color: HomeDashboardTheme.labelTertiary,
                                    size: 28.sp,
                                  ),
                                ),
                              )
                            : Container(
                                width: 96.w,
                                height: 72.h,
                                color: HomeDashboardTheme.fillSecondary,
                                child: Icon(
                                  Icons.article_outlined,
                                  color: HomeDashboardTheme.labelTertiary,
                                  size: 28.sp,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
