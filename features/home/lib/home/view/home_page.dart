import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/home_controller.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_home/home/view/widgets/home_club_tab_content.dart';
import 'package:module_home/home/view/widgets/home_dashboard_widgets.dart';
import 'package:module_home/home/view/widgets/home_top_tab_bar.dart';
import 'package:module_home/home/view/widgets/home_video_tab_content.dart';
import 'package:module_music/controller/music_playback_controller.dart';
import 'package:module_music/widgets/music_mini_player_bar.dart';
import 'package:wys_router/src/route/route_path.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(HomeController.new, fenix: true);
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.mainTabRoot,
      body: Obx(() {
        final data = controller.dashboard.value;
        final error = controller.errorMessage.value;
        controller.userGreeting.value;
        controller.selectedTopTab.value;
        controller.selectedMetricTab.value;
        final bottomInset = _musicBottomInset(context);

        if (data == null) {
          return _buildPlaceholder(error);
        }

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 840
                  ? HomeDashboardTheme.contentMaxWidth
                  : double.infinity;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: AppRefreshView(
                    onRefresh: controller.refreshDashboard,
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: AppSafeInsets.top(context) + 16,
                        bottom: 24.h,
                      ),
                      children: [
                        HomeGreetingSection(
                          greeting: controller.userGreeting.value,
                        ),
                        const HomeSearchBar(),
                        HomeTopTabBar(
                          selectedIndex: controller.selectedTopTab.value,
                          onSelected: controller.selectTopTab,
                        ),
                        _buildTopTabBody(data),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  double _musicBottomInset(BuildContext context) {
    if (!Get.isRegistered<MusicPlaybackController>()) return 0;
    final playback = Get.find<MusicPlaybackController>();
    // Subscribe so inset updates when the mini player appears/disappears.
    playback.playerState.value;
    playback.currentIndex.value;
    return MusicMiniPlayerBar.bottomInsetForHomeSession(context);
  }

  Widget _buildPlaceholder(String? error) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error,
              style: HomeDashboardTheme.sectionLabel,
            ),
            SizedBox(height: 12.h),
            FilledButton(
              onPressed: controller.retryInitialLoad,
              style: FilledButton.styleFrom(
                backgroundColor: HomeDashboardTheme.accent,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildTopTabBody(HomeDashboardData data) {
    return switch (controller.selectedTopTab.value) {
      1 => const HomeVideoTabContent(),
      2 => const HomeClubTabContent(),
      _ => _buildHomeDashboard(data),
    };
  }

  Widget _buildHomeDashboard(HomeDashboardData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeBannerSection(),
        HomeFeatureGrid(items: data.features),
        HomeQuickActionGrid(actions: data.quickActions),
        HomeStoreMetricsCard(
          storeName: data.storeName,
          selectedTab: controller.selectedMetricTab.value,
          tabs: HomeController.metricTabs,
          metrics: controller.currentMetrics,
          details: data.metricDetails,
          onTabSelected: controller.selectMetricTab,
        ),
        _StrategyEntry(onTap: () => Get.toNamed(RoutePath.homeStrategy)),
        HomeServiceGrid(items: data.services),
        HomeContactList(items: data.contacts),
        HomeNewsList(items: data.news),
        _LearningReportEntry(
          onTap: () => Get.toNamed(RoutePath.homeLearningReport),
        ),
      ],
    );
  }
}

class _StrategyEntry extends StatelessWidget {
  const _StrategyEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Material(
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
              border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
            ),
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: HomeDashboardTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: 24.sp,
                    color: HomeDashboardTheme.accent,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '投资策略',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: HomeDashboardTheme.labelPrimary,
                        ),
                      ),
                      Text(
                        '资产九宫格 · 恐贪定投 · 趋势策略',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: HomeDashboardTheme.labelSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: HomeDashboardTheme.labelTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningReportEntry extends StatelessWidget {
  const _LearningReportEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Material(
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: HomeDashboardTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 24.sp,
                    color: HomeDashboardTheme.accent,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '学习报告',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: HomeDashboardTheme.labelPrimary,
                        ),
                      ),
                      Text(
                        '今日高光 · 学习记录',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: HomeDashboardTheme.labelSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: HomeDashboardTheme.labelTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
