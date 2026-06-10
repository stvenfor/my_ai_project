import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.retryableTypes = const {
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    },
    List<Duration>? retryDelays,
  })  : _dio = dio,
        retryDelays = retryDelays ??
            List<Duration>.generate(
              maxRetries,
              (index) => Duration(milliseconds: 500 * (index + 1)),
            );

  final Dio _dio;
  final int maxRetries;
  final Set<DioExceptionType> retryableTypes;
  final List<Duration> retryDelays;

  static const _retryCountKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final retryCount = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    final delay = retryDelays[retryCount.clamp(0, retryDelays.length - 1)];
    await Future<void>.delayed(delay);

    final requestOptions = err.requestOptions;
    requestOptions.extra[_retryCountKey] = retryCount + 1;

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (error) {
      if (error is DioException) {
        handler.next(error);
      } else {
        handler.next(err);
      }
    }
  }

  bool _shouldRetry(DioException err) {
    if (retryableTypes.contains(err.type)) return true;
    final statusCode = err.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }
}
