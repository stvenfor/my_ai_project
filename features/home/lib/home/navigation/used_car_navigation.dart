import 'package:get/get.dart';
import 'package:module_auth/module_auth.dart';
import 'package:module_route/route/route_path.dart';

/// 二手车列表页入口：已登录直接进入，未登录 modal 登录后回跳。
abstract final class UsedCarNavigation {
  static Future<void> open() async {
    if (AuthSession.isLoggedIn) {
      await Get.toNamed(RoutePath.homeUsedCarList);
      return;
    }
    await AuthNavigation.openLogin(redirectRoute: RoutePath.homeUsedCarList);
  }
}
