import 'package:get/get.dart';
import 'package:module_auth/session/user_service_impl.dart';
import 'package:module_core/core.dart';

/// 登录模块会话入口：注册/读取/清除 UserService。
class AuthSession {
  AuthSession._();

  /// 注册全局 [UserService]（壳工程与独立运行均需调用，幂等）。
  static Future<UserService> register({bool permanent = true}) async {
    if (Get.isRegistered<UserService>()) {
      return Get.find<UserService>();
    }
    await Get.putAsync<UserService>(UserServiceImpl.create, permanent: permanent);
    return Get.find<UserService>();
  }

  /// 登出并清除本地缓存。
  static Future<void> logout() async {
    if (!Get.isRegistered<UserService>()) return;
    await Get.find<UserService>().clearUser();
  }

  static UserService? get maybeService =>
      Get.isRegistered<UserService>() ? Get.find<UserService>() : null;

  static bool get isLoggedIn => maybeService?.isLoggedIn ?? false;
}
