import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_http/module_http.dart';
import 'package:module_repository/repository/api.dart';

/// 统一 HTTP 初始化，读取 [EnvironmentService] 当前环境 baseUrl。
class AppHttpBootstrap {
  AppHttpBootstrap._();

  static String resolveBaseUrl() {
    if (Get.isRegistered<EnvironmentService>()) {
      return Get.find<EnvironmentService>().baseUrl;
    }
    return EnvConfig.of(AppEnv.test).baseUrl;
  }

  static String resolveEnvLabel() {
    if (Get.isRegistered<EnvironmentService>()) {
      return Get.find<EnvironmentService>().config.label;
    }
    return EnvConfig.of(AppEnv.test).label;
  }

  static void initialize({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    bool enableLog = false,
    int maxRetries = 0,
  }) {
    _apply(
      headerProvider: headerProvider,
      responseHook: responseHook,
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }

  static void reinitialize({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    bool enableLog = false,
    int maxRetries = 0,
  }) {
    _apply(
      headerProvider: headerProvider,
      responseHook: responseHook,
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }

  static void _apply({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    required bool enableLog,
    required int maxRetries,
  }) {
    final config = HttpClientConfig(
      baseUrl: resolveBaseUrl(),
      headerProvider: headerProvider,
      responseHook: responseHook,
      responseParser: const WanAndroidResponseParser(),
      enableLog: enableLog,
      maxRetries: maxRetries,
      interceptors: [
        EnvHeaderInterceptor(resolveEnvLabel),
      ],
    );

    if (HttpManager.instance.isInitialized) {
      HttpManager.instance.reinit(config);
    } else {
      HttpManager.instance.init(config);
    }
  }
}
