import 'package:module_http/module_http.dart';
import 'package:module_home/legacy/wanandroid/wanandroid_api.dart';

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
      headerProvider: headerProvider,
      responseHook: responseHook,
      responseParser: const WanAndroidResponseParser(),
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }
}
