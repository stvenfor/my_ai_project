import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_http/http/backend_http_config.dart';
import 'package:module_http/http/backend_response_parser.dart';
import 'package:module_http/http/env_header_interceptor.dart';
import 'package:module_http/http/http.dart';
import 'package:module_http/http/rsp_interceptor.dart';

/// my_go_study HTTP 初始化，读取当前环境 [backendBaseUrl]。
class AppHttpBootstrap {
  AppHttpBootstrap._();

  static String resolveBaseUrl() => BackendHttpConfig.resolveBackendBaseUrl();

  /// HTTP 请求头 `X-App-Env` 须为 ASCII，使用 [AppEnv.name]（test/staging/production）。
  static String resolveEnvLabel() {
    if (Get.isRegistered<EnvironmentService>()) {
      return Get.find<EnvironmentService>().currentEnv.value.name;
    }
    return AppEnv.test.name;
  }

  static void initialize({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    HttpResponseParser responseParser = const BackendResponseParser(),
    bool enableLog = false,
    int maxRetries = 0,
    List<Interceptor> interceptors = const [],
  }) {
    _apply(
      headerProvider: headerProvider,
      responseHook: responseHook,
      responseParser: responseParser,
      enableLog: enableLog,
      maxRetries: maxRetries,
      interceptors: interceptors,
    );
  }

  static void reinitialize({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    HttpResponseParser responseParser = const BackendResponseParser(),
    bool enableLog = false,
    int maxRetries = 0,
    List<Interceptor> interceptors = const [],
  }) {
    _apply(
      headerProvider: headerProvider,
      responseHook: responseHook,
      responseParser: responseParser,
      enableLog: enableLog,
      maxRetries: maxRetries,
      interceptors: interceptors,
    );
  }

  static void _apply({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    required HttpResponseParser responseParser,
    required bool enableLog,
    required int maxRetries,
    List<Interceptor> interceptors = const [],
  }) {
    final config = HttpClientConfig(
      baseUrl: resolveBaseUrl(),
      headerProvider: headerProvider,
      responseHook: responseHook,
      responseParser: responseParser,
      enableLog: enableLog,
      maxRetries: maxRetries,
      interceptors: [
        ...interceptors,
        EnvHeaderInterceptor(resolveEnvLabel),
      ],
      // 4xx/5xx 仍交给 BackendResponseParser 解析 { code, message } 信封。
      validateStatus: (status) => status != null && status >= 200 && status < 600,
    );

    if (HttpManager.instance.isInitialized) {
      HttpManager.instance.reinit(config);
    } else {
      HttpManager.instance.init(config);
    }
  }
}
