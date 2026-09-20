import 'package:get/get.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/view/login_page.dart';
import 'package:wys_router/src/route/login_redirect.dart';
import 'package:wys_router/src/route/route_path.dart';

/// 登录模块统一导航入口（Invite Login / Force Reset Login）。
abstract final class AuthNavigation {
  /// Invite Login：以 modal 方式打开登录门。
  ///
  /// [redirectRoute] 登录成功后通过 [LoginRedirect] 回跳。
  static Future<void> openLogin({String? redirectRoute}) async {
    if (redirectRoute != null) {
      LoginRedirect.setPending(redirectRoute);
    }
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    await Get.to<void>(
      () => const LoginPage(),
      routeName: RoutePath.login,
      transition: Transition.downToUp,
      fullscreenDialog: true,
    );
  }

  /// Force Reset Login：清栈并停在登录门（会话失效 / 登出成功后）。
  static Future<void> resetToLogin() async {
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    if (Get.currentRoute == RoutePath.login) return;
    await Get.offAllNamed(RoutePath.login);
  }
}
