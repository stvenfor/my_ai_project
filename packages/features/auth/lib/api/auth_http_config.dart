import 'package:module_http/module_http.dart';

/// module_auth 内 HTTP 初始化（my_go_study）。
class AuthHttpConfig {
  static void ensureInitialized({
    HttpHeaderProvider? headerProvider,
    bool enableLog = false,
    int maxRetries = 0,
  }) {
    // 登录前同步当前环境 baseUrl（避免早于 EnvironmentService 注册时的旧地址）。
    AppHttpBootstrap.reinitialize(
      headerProvider: headerProvider ?? const AuthHeaderProvider(),
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }
}
