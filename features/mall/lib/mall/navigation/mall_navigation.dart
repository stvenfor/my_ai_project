import 'package:get/get.dart';
import 'package:module_auth/navigation/auth_navigation.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:wys_router/src/route/route_path.dart';

/// 商城入口导航（供我的页等跨模块调用，禁止互相 import 页面）。
abstract final class MallNavigation {
  static Future<void> openMall() async {
    if (!AuthSession.isLoggedIn) {
      await AuthNavigation.openLogin(redirectRoute: RoutePath.mall);
      return;
    }
    await Get.toNamed(RoutePath.mall);
  }

  static Future<void> openOrders() async {
    if (!AuthSession.isLoggedIn) {
      await AuthNavigation.openLogin(redirectRoute: RoutePath.mallOrders);
      return;
    }
    await Get.toNamed(RoutePath.mallOrders);
  }
}
