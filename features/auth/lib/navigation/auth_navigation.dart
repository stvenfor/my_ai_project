import 'package:get/get.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/view/login_page.dart';
import 'package:module_route/route/login_redirect.dart';
import 'package:module_route/route/route_path.dart';

/// 登录模块统一导航入口。
abstract final class AuthNavigation {
  /// 以 modal 方式（自底部向上）打开完整登录路由栈。
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
}
