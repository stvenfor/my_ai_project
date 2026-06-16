import 'package:flutter/widgets.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_sample/pages/main_page.dart';
import 'package:module_sample/pages/splash_page.dart';

/// 主工程壳路由（不依赖具体业务模块）。
class AppRouteContainer {
  Map<String, WidgetBuilder> installShellRouters() {
    return {
      RoutePath.splash: (context) => const SplashPage(),
      RoutePath.main: (context) => const MainPage(),
      ...WebKitRoutes.routes(),
    };
  }
}
