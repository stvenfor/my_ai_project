import 'package:get/get.dart';
import 'package:module_auth/session/user_service_impl.dart';
import 'package:module_core/core.dart';
import 'package:module_supabase/module_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 登录模块会话入口：注册 AuthService + UserService（Mock 或 Supabase）。
class AuthSession {
  AuthSession._();

  /// 注册全局认证与会话服务（壳工程与独立运行均需调用，幂等）。
  ///
  /// [useMock] 为 true 时使用本地 Mock；为 null 时读取 [SupabaseConfig.useMockAuth]。
  static Future<void> register({
    bool? useMock,
    bool permanent = true,
  }) async {
    final mock = useMock ?? SupabaseConfig.useMockAuth;

    if (mock) {
      await _registerMock(permanent: permanent);
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      throw const SupabaseConfigFailure(
        '未加载 Supabase 配置，请使用 flutter run --dart-define-from-file=.env 启动',
      );
    }

    final configIssue = SupabaseConfig.configurationIssue;
    if (configIssue != null) {
      throw SupabaseConfigFailure(configIssue);
    }

    await SupabaseBootstrap.initialize();

    if (!Get.isRegistered<UserService>()) {
      late final UserServiceBridge bridge;
      final authService = SupabaseAuthService(
        Supabase.instance.client,
        onAuthenticated: () => bridge.syncFromCurrentSession(),
      );
      Get.put<AuthService>(authService, permanent: permanent);

      bridge = UserServiceBridge(
        authService: authService,
        client: Supabase.instance.client,
      );
      await bridge.init();
      Get.put<UserService>(bridge, permanent: permanent);
      return;
    }

    if (!Get.isRegistered<AuthService>()) {
      final bridge = Get.find<UserService>() as UserServiceBridge;
      Get.put<AuthService>(
        SupabaseAuthService(
          Supabase.instance.client,
          onAuthenticated: bridge.syncFromCurrentSession,
        ),
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

  /// 登出：优先走 [AuthService.signOut]。
  static Future<void> logout() async {
    if (Get.isRegistered<AuthService>()) {
      await Get.find<AuthService>().signOut();
      return;
    }
    if (!Get.isRegistered<UserService>()) return;
    await Get.find<UserService>().clearUser();
  }

  static UserService? get maybeService =>
      Get.isRegistered<UserService>() ? Get.find<UserService>() : null;

  static bool get isLoggedIn => maybeService?.isLoggedIn ?? false;
}
