import 'package:module_http/module_http.dart';

/// module_auth 内 HTTP 初始化（my_go_study）。
/// 壳层已挂 SessionGuard / Refresh；已初始化则不再重建，避免冲掉 interceptor。
class AuthHttpConfig {
  static void ensureInitialized({
    HttpHeaderProvider? headerProvider,
    bool enableLog = false,
    int maxRetries = 0,
  }) {
    if (HttpManager.instance.isInitialized) return;
    AppHttpBootstrap.initialize(
      headerProvider: headerProvider ?? const AuthHeaderProvider(),
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }
}
