import 'package:get/get.dart';
import 'package:module_auth/session/backend_auth_service.dart';
import 'package:module_auth/session/user_service_impl.dart';
import 'package:module_auth/session/session_recovery.dart';
import 'package:module_core/core.dart';

/// 登录模块会话入口：注册 AuthService + UserService（Mock 或 my_go_study HTTP）。
class AuthSession {
  AuthSession._();

  /// 登录成功后回调（Realtime 等基础设施注册）。
  static Future<void> Function()? onAfterLogin;

  /// 登出完成后回调。
  static Future<void> Function()? onAfterLogout;

  static Future<void> notifyAfterLogin() async {
    await onAfterLogin?.call();
  }

  /// 注册全局认证与会话服务（壳工程与独立运行均需调用，幂等）。
  ///
  /// [useMock] 为 true 时使用本地 Mock；为 null 时读取 [AppAuthConfig.useMockAuth]。
  /// 默认使用 my_go_study `/api/v1/user/*`（邮箱密码），由 Go 后端代理 Supabase Auth。
  static Future<void> register({
    bool? useMock,
    bool permanent = true,
  }) async {
    final mock = useMock ?? AppAuthConfig.useMockAuth;

    if (mock) {
      await _registerMock(permanent: permanent);
      return;
    }

    await _registerBackend(permanent: permanent);
  }

  static Future<void> _registerBackend({required bool permanent}) async {
    if (!Get.isRegistered<UserService>()) {
      await Get.putAsync<UserService>(
        UserServiceImpl.create,
        permanent: permanent,
      );
    }
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        BackendAuthService(Get.find<UserService>()),
        permanent: permanent,
      );
    }
  }

  static Future<void> _registerMock({required bool permanent}) async {
    if (!Get.isRegistered<UserService>()) {
      await Get.putAsync<UserService>(
        UserServiceImpl.create,
        permanent: permanent,
      );
    }
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(
        MockAuthService(Get.find<UserService>()),
        permanent: permanent,
      );
    }
  }

  /// 启动时静默 refresh（本地已有 refresh_token 时）。
  static Future<void> refreshIfNeeded() async {
    if (!isLoggedIn || !Get.isRegistered<AuthService>()) return;
    await SessionRecovery.syncStoredDeviceId();
    final auth = Get.find<AuthService>();
    if (auth is SessionRefreshable) {
      await (auth as SessionRefreshable).refreshSession();
    }
  }

  /// 登出：优先走 [AuthService.signOut]。
  static Future<void> logout() async {
    if (Get.isRegistered<AuthService>()) {
      await Get.find<AuthService>().signOut();
    } else if (Get.isRegistered<UserService>()) {
      await Get.find<UserService>().clearUser();
    }
    await onAfterLogout?.call();
  }

  static UserService? get maybeService =>
      Get.isRegistered<UserService>() ? Get.find<UserService>() : null;

  static bool get isLoggedIn => maybeService?.isLoggedIn ?? false;
}
