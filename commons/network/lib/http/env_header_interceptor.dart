import 'package:dio/dio.dart';

/// 请求头注入当前环境标识（ASCII，如 test/staging/production），便于联调排查。
class EnvHeaderInterceptor extends Interceptor {
  EnvHeaderInterceptor(this.envLabelProvider);

  final String Function() envLabelProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-App-Env'] = envLabelProvider();
    handler.next(options);
  }
}
