import 'package:get/get.dart';
import 'package:module_core/model/user.dart';
import 'package:module_core/service/user_service.dart';

/// 登录态生命周期钩子（供 Realtime / IM / Linking 等 components 注册）。
///
/// 实现与注册仍在 features/auth；components 只依赖本抽象，不依赖 module_auth。
class AuthLifecycle {
  AuthLifecycle._();

  /// 登录成功后回调。
  static Future<void> Function()? onAfterLogin;

  /// 登出完成后回调。
  static Future<void> Function()? onAfterLogout;

  static Future<void> notifyAfterLogin() async {
    await onAfterLogin?.call();
  }

  static Future<void> notifyAfterLogout() async {
    await onAfterLogout?.call();
  }

  static UserService? get maybeUserService =>
      Get.isRegistered<UserService>() ? Get.find<UserService>() : null;

  static bool get isLoggedIn => maybeUserService?.isLoggedIn ?? false;

  static User? get currentUser => maybeUserService?.currentUser.value;
}
