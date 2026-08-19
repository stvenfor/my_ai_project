/// 应用认证开关（通过 --dart-define 或 --dart-define-from-file=.env 注入）。
///
/// Flutter 不直连 Supabase；`USE_MOCK_AUTH=false` 时所有认证与业务请求经 Go BFF。
class AppAuthConfig {
  AppAuthConfig._();

  /// 为 true 时使用 Mock 认证（本地调试，不请求 Go 后端）。
  static const useMockAuth =
      bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: false);
}
