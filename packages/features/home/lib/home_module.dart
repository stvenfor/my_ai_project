import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/api/home_http_config.dart';
import 'package:module_home/home/view/check_in_mall_page.dart';
import 'package:module_home/home/view/home_learning_report_page.dart';
import 'package:module_home/home/view/home_page.dart';
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
        icon: Icons.home_rounded,
        selectedIcon: Icons.home_rounded,
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
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    HomeHttpConfig.ensureInitialized(
      enableLog: context.enableHttpLog,
      maxRetries: context.httpMaxRetries,
    );
    if (context.isStandalone) {
      HomeBinding().dependencies();
    }
  }
}
