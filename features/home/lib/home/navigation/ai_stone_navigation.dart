import 'package:get/get.dart';
import 'package:module_auth/module_auth.dart';
import 'package:wys_router/src/route/route_path.dart';

/// AI 小石头入口：已登录直接进入，未登录 modal 登录后回跳。
///
/// 放在 home 内，避免 `module_home → module_ai` 跨 feature 依赖页面包。
abstract final class AiStoneNavigation {
  static Future<void> open() async {
    if (AuthSession.isLoggedIn) {
      await Get.toNamed(RoutePath.aiStream);
      return;
    }
    await AuthNavigation.openLogin(redirectRoute: RoutePath.aiStream);
  }
}
