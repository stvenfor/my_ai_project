import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/api/home_http_config.dart';
import 'package:module_home/home/view/all_services_page.dart';
import 'package:module_home/home/view/check_in_mall_page.dart';
import 'package:module_home/home/view/dubbing_home_page.dart';
import 'package:module_home/home/view/home_learning_report_page.dart';
import 'package:module_home/home/view/home_page.dart';
import 'package:module_home/home/view/strategy_page.dart';
import 'package:module_home/home/view/hot_rank_detail_page.dart';
import 'package:module_home/home/view/search_page.dart';
import 'package:module_home/home/binding/used_car_binding.dart';
import 'package:module_home/home/view/used_car_detail_page.dart';
import 'package:module_home/home/view/used_car_list_page.dart';
import 'package:module_home/home/web/home_web_handlers.dart';
import 'package:module_core/core.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_tab_item.dart';
import 'package:module_route/route/route_path.dart';

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
        RoutePath.homeUsedCarList: (_) {
          UsedCarListBinding().dependencies();
          return const UsedCarListPage();
        },
        RoutePath.homeUsedCarDetail: (_) {
          UsedCarDetailBinding().dependencies();
          return const UsedCarDetailPage();
        },
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
