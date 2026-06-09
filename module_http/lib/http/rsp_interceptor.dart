import 'package:dio/dio.dart';

abstract interface class HttpResponseHook {
  void onResponse(Response<dynamic> response);

  void onError(DioException error);
}

class RspInterceptor extends Interceptor {
  RspInterceptor(this.hook);

  final HttpResponseHook hook;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    hook.onResponse(response);
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    hook.onError(err);
    handler.next(err);
  }
}
