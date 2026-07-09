import 'package:module_http/module_http.dart';

/// module_home 内 HTTP 初始化（my_go_study）。
class HomeHttpConfig {
  static String get baseUrl => AppHttpBootstrap.resolveBaseUrl();

  static void ensureInitialized({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    bool enableLog = false,
    int maxRetries = 0,
  }) {
    if (HttpManager.instance.isInitialized) return;
    initHttp(
      headerProvider: headerProvider,
      responseHook: responseHook,
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }

  static void initHttp({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    bool enableLog = false,
    int maxRetries = 0,
  }) {
    AppHttpBootstrap.initialize(
      headerProvider: headerProvider ?? const AuthHeaderProvider(),
      responseHook: responseHook,
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }
}
