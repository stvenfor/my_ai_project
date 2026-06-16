import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/home_controller.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_home/home/view/widgets/home_dashboard_widgets.dart';
import 'package:module_route/route/route_path.dart';

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
      backgroundColor: HomeDashboardTheme.background,
      body: Obx(() {
        final data = controller.dashboard.value;
        if (data == null) {
          if (controller.errorMessage.value != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.errorMessage.value ?? '加载失败'),
                  SizedBox(height: 12.h),
                  FilledButton(
                    onPressed: controller.retryInitialLoad,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }

        return AppRefreshView(
          onRefresh: controller.refreshDashboard,
          child: CustomScrollView(
            slivers: [
            SliverToBoxAdapter(
                child: ColoredBox(
                color: HomeDashboardTheme.bannerDark,
                child: Padding(
                  padding: EdgeInsets.only(top: AppSafeInsets.top(context)),
                  child: Column(
                    children: [
                      const HomeSearchBar(),
                      const HomeBannerSection(),
                      HomeFeatureGrid(items: data.features),
                     SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 20.h,
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.bannerDark,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ColoredBox(
                color: HomeDashboardTheme.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => HomeGreetingSection(
                        greeting: controller.userGreeting.value,
                      ),
                    ),
                    HomeQuickActionGrid(actions: data.quickActions),
                    Obx(
                      () => HomeStoreMetricsCard(
                        storeName: data.storeName,
                        selectedTab: controller.selectedMetricTab.value,
                        tabs: HomeController.metricTabs,
                        metrics: controller.currentMetrics,
                        details: data.metricDetails,
                        onTabSelected: controller.selectMetricTab,
                      ),
                    ),
                    HomeServiceGrid(items: data.services),
                    HomeContactList(items: data.contacts),
                    HomeNewsList(items: data.news),
                    _LearningReportEntry(
                      onTap: () => Get.toNamed(RoutePath.homeLearningReport),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        );
      }),
    );
  }
}

class _LearningReportEntry extends StatelessWidget {
  const _LearningReportEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      child: Material(
        color: HomeDashboardTheme.cardWhite,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Text('📊', style: TextStyle(fontSize: 28.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '学习报告',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '今日高光 · 学习记录',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: HomeDashboardTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: HomeDashboardTheme.textGray),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
