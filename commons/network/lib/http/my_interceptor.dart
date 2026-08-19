import 'package:dio/dio.dart';

import 'http.dart';

class HeaderInterceptor extends Interceptor {
  HeaderInterceptor(this.headerProvider);

  final HttpHeaderProvider headerProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final headers = await headerProvider.getHeaders(options);
      options.headers.addAll(headers);
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          message: error.toString(),
          type: DioExceptionType.unknown,
        ),
      );
    }
  }
}
