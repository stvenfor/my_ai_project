import 'package:get/get.dart';
import 'package:module_auth/module_auth.dart';
import 'package:wys_router/src/route/route_path.dart';

/// 新车跟进入口：已登录直接进入，未登录 modal 登录后回跳。
abstract final class NewCarFollowNavigation {
  static Future<void> open() async {
    if (AuthSession.isLoggedIn) {
      await Get.toNamed(RoutePath.homeNewCarFollow);
      return;
    }
    await AuthNavigation.openLogin(redirectRoute: RoutePath.homeNewCarFollow);
  }
}
