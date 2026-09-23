import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/api/home_http_config.dart';
import 'package:module_home/home/view/all_services_page.dart';
import 'package:module_home/home/view/check_in_mall_page.dart';
import 'package:module_home/home/view/dubbing_home_page.dart';
import 'package:module_home/home/view/home_feature_content_page.dart';
import 'package:module_home/home/view/home_learning_report_page.dart';
import 'package:module_home/home/view/home_page.dart';
import 'package:module_home/home/view/strategy_page.dart';
import 'package:module_home/home/view/hot_rank_detail_page.dart';
import 'package:module_home/home/view/search_page.dart';
import 'package:module_home/home/view/widgets/home_club_tab_content.dart';
import 'package:module_home/home/view/widgets/home_video_tab_content.dart';
import 'package:module_home/home/binding/analytics_binding.dart';
import 'package:module_home/home/binding/used_car_binding.dart';
import 'package:module_home/home/view/analytics_detail_page.dart';
import 'package:module_home/home/view/analytics_list_page.dart';
import 'package:module_home/home/view/home_todo_pages.dart';
import 'package:module_home/home/view/ledger_detail_page.dart';
import 'package:module_home/home/view/ledger_list_page.dart';
import 'package:module_home/home/view/used_car_create_page.dart';
import 'package:module_home/home/view/used_car_detail_page.dart';
import 'package:module_home/home/view/used_car_list_page.dart';
import 'package:module_home/after_sales/after_sales_binding.dart';
import 'package:module_home/after_sales/view/after_sales_create_page.dart';
import 'package:module_home/after_sales/view/after_sales_detail_page.dart';
import 'package:module_home/after_sales/view/after_sales_list_page.dart';
import 'package:module_home/home/web/home_web_handlers.dart';
import 'package:module_home/new_car_follow/new_car_follow_binding.dart';
import 'package:module_home/new_car_follow/view/new_car_follow_create_page.dart';
import 'package:module_home/new_car_follow/view/new_car_follow_detail_page.dart';
import 'package:module_home/new_car_follow/view/new_car_follow_list_page.dart';
import 'package:module_core/core.dart';
import 'package:wys_router/src/module/feature_module.dart';
import 'package:wys_router/src/module/module_host_context.dart';
import 'package:wys_router/src/module/module_tab_item.dart';
import 'package:wys_router/src/route/route_path.dart';

class HomeModule extends FeatureModule {
  @override
  String get moduleId => 'home';

  @override
  ModuleTabItem? get mainTab => ModuleTabItem(
        moduleId: moduleId,
        label: '首页',
        icon: CupertinoIcons.house,
        selectedIcon: CupertinoIcons.house_fill,
        pageBuilder: () => const HomePage(),
        order: 0,
      );

  @override
  Bindings? createBinding() => HomeBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.home: (_) => const HomePage(),
        RoutePath.homeLearningReport: (_) => const HomeLearningReportPage(),
        RoutePath.homeCheckInMall: (_) => const CheckInMallPage(),
        RoutePath.homeAllServices: (_) => const AllServicesPage(),
        RoutePath.homeSearch: (_) => const SearchPage(),
        RoutePath.homeStrategy: (_) => const StrategyPage(),
        RoutePath.homeDubbingFeed: (_) => const DubbingHomePage(),
        RoutePath.homeHotRankDetail: (_) => const HotRankDetailPage(),
        RoutePath.homeLifeService: (_) => const HomeFeatureContentPage(
              title: '生活服务',
              child: HomeVideoTabContent(),
            ),
        RoutePath.homeLiveCommerce: (_) => const HomeFeatureContentPage(
              title: '直播带货',
              child: HomeClubTabContent(),
            ),
        RoutePath.homeClub: (_) => const HomeFeatureContentPage(
              title: 'Club',
              child: HomeClubTabContent(),
            ),
        RoutePath.homeUsedCarList: (_) {
          UsedCarListBinding().dependencies();
          return const UsedCarListPage();
        },
        RoutePath.homeUsedCarDetail: (_) {
          UsedCarDetailBinding().dependencies();
          return const UsedCarDetailPage();
        },
        RoutePath.homeUsedCarCreate: (_) {
          UsedCarCreateBinding().dependencies();
          return const UsedCarCreatePage();
        },
        RoutePath.homeLedgerList: (_) {
          LedgerListBinding().dependencies();
          return const LedgerListPage();
        },
        RoutePath.homeLedgerDetail: (_) {
          LedgerDetailBinding().dependencies();
          return const LedgerDetailPage();
        },
        RoutePath.homeDataAnalyticsList: (_) {
          AnalyticsListBinding().dependencies();
          return const AnalyticsListPage();
        },
        RoutePath.homeDataAnalyticsDetail: (_) {
          AnalyticsDetailBinding().dependencies();
          return const AnalyticsDetailPage();
        },
        RoutePath.homeTodoPartnerPending: (_) => const PartnerPendingPage(),
        RoutePath.homeTodoFollowUp: (_) => const FollowUpCustomersPage(),
        RoutePath.homeTodoAfterSales: (_) => const AfterSalesAppointmentsPage(),
        RoutePath.homeTodoOrderReview: (_) => const StoreReviewOrdersPage(),
        RoutePath.homeAfterSalesList: (_) {
          AfterSalesListBinding().dependencies();
          return const AfterSalesListPage();
        },
        RoutePath.homeAfterSalesCreate: (_) => const AfterSalesCreatePage(),
        RoutePath.homeAfterSalesDetail: (_) => const AfterSalesDetailPage(),
        RoutePath.homeNewCarFollow: (_) {
          NewCarFollowListBinding().dependencies();
          return const NewCarFollowListPage();
        },
        RoutePath.homeNewCarFollowCreate: (_) =>
            const NewCarFollowCreatePage(),
        RoutePath.homeNewCarFollowDetail: (_) =>
            const NewCarFollowDetailPage(),
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    HomeHttpConfig.ensureInitialized(
      enableLog: context.enableHttpLog,
      maxRetries: context.httpMaxRetries,
    );
    if (Get.isRegistered<WebBridgeRegistry>()) {
      HomeWebHandlers.register(Get.find<WebBridgeRegistry>());
    }
    if (context.isStandalone) {
      HomeBinding().dependencies();
    }
  }
}
