import 'dart:async';

import 'package:dio/dio.dart';

import 'log_print_interceptor.dart';
import 'my_interceptor.dart';
import 'retry_interceptor.dart';
import 'rsp_interceptor.dart';

typedef JsonConverter<T> = T Function(dynamic json);

enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  head('HEAD');

  const HttpMethod(this.value);

  final String value;
}

abstract interface class HttpHeaderProvider {
  FutureOr<Map<String, dynamic>> getHeaders(RequestOptions options);
}

abstract interface class HttpResponseParser {
  HttpResult<T> parse<T>(
    Response<dynamic> response, {
    JsonConverter<T>? converter,
  });
}

abstract interface class HttpErrorConverter {
  HttpRequestException convert(Object error, StackTrace stackTrace);
}

class HttpClientConfig {
  const HttpClientConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
    this.headers = const {},
    this.responseType = ResponseType.json,
    this.followRedirects = true,
    this.enableLog = false,
    this.headerProvider,
    this.responseParser = const DefaultHttpResponseParser(),
    this.errorConverter,
    this.responseHook,
    this.interceptors = const [],
    this.maxRetries = 0,
    this.validateStatus,
    this.logger,
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Map<String, dynamic> headers;
  final ResponseType responseType;
  final bool followRedirects;
  final bool enableLog;
  final HttpHeaderProvider? headerProvider;
  final HttpResponseParser responseParser;
  final HttpErrorConverter? errorConverter;
  final HttpResponseHook? responseHook;
  final List<Interceptor> interceptors;
  final int maxRetries;
  final ValidateStatus? validateStatus;
  final void Function(String message)? logger;
}

class HttpResult<T> {
  const HttpResult({
    required this.success,
    this.data,
    this.code,
    this.message,
    this.rawData,
    this.response,
  });

  factory HttpResult.success({
    T? data,
    int? code,
    String? message,
    dynamic rawData,
    Response<dynamic>? response,
  }) {
    return HttpResult<T>(
      success: true,
      data: data,
      code: code,
      message: message,
      rawData: rawData,
      response: response,
    );
  }

  factory HttpResult.failure({
    int? code,
    String? message,
    dynamic rawData,
    Response<dynamic>? response,
  }) {
    return HttpResult<T>(
      success: false,
      code: code,
      message: message,
      rawData: rawData,
      response: response,
    );
  }

  final bool success;
  final T? data;
  final int? code;
  final String? message;
  final dynamic rawData;
  final Response<dynamic>? response;
}

class DefaultHttpResponseParser implements HttpResponseParser {
  const DefaultHttpResponseParser();

  @override
  HttpResult<T> parse<T>(
    Response<dynamic> response, {
    JsonConverter<T>? converter,
  }) {
    return HttpResult<T>.success(
      data: _convertData(response.data, converter),
      code: response.statusCode,
      message: response.statusMessage,
      rawData: response.data,
      response: response,
    );
  }

  T? _convertData<T>(dynamic rawData, JsonConverter<T>? converter) {
    if (converter != null) return converter(rawData);
    if (rawData == null) return null;
    if (rawData is T) return rawData;
    return rawData as T;
  }
}

class HttpRequestException implements Exception {
  HttpRequestException({
    required this.message,
    this.code,
    this.statusCode,
    this.data,
    this.origin,
    this.stackTrace,
  });

  factory HttpRequestException.from(Object error, StackTrace stackTrace) {
    if (error is HttpRequestException) return error;
    if (error is DioException) {
      return HttpRequestException.fromDio(error, stackTrace);
    }
    return HttpRequestException(
      message: error.toString(),
      origin: error,
      stackTrace: stackTrace,
    );
  }

  factory HttpRequestException.fromDio(
    DioException error,
    StackTrace stackTrace,
  ) {
    final response = error.response;
    return HttpRequestException(
      message: _messageFromDio(error),
      code: error.type.name,
      statusCode: response?.statusCode,
      data: response?.data,
      origin: error,
      stackTrace: stackTrace,
    );
  }

  final String message;
  final String? code;
  final int? statusCode;
  final dynamic data;
  final Object? origin;
  final StackTrace? stackTrace;

  static String _messageFromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时';
      case DioExceptionType.sendTimeout:
        return '请求发送超时';
      case DioExceptionType.receiveTimeout:
        return '响应接收超时';
      case DioExceptionType.badCertificate:
        return '证书校验失败';
      case DioExceptionType.badResponse:
        return error.response?.statusMessage ?? '服务器响应异常';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接异常';
      case DioExceptionType.unknown:
        return error.message ?? '未知网络异常';
    }
  }

  @override
  String toString() {
    final status = statusCode == null ? '' : ', statusCode: $statusCode';
    final errorCode = code == null ? '' : ', code: $code';
    return 'HttpRequestException(message: $message$errorCode$status)';
  }
}

class HttpManager {
  HttpManager._();

  static final HttpManager instance = HttpManager._();

  Dio? _dio;
  HttpClientConfig? _config;

  bool get isInitialized => _dio != null && _config != null;

  Dio get dio => _requireDio();

  HttpClientConfig get config {
    final currentConfig = _config;
    if (currentConfig == null) {
      throw StateError('HttpManager has not been initialized.');
    }
    return currentConfig;
  }

  void init(HttpClientConfig config, {Dio? dio}) {
    _applyConfig(config, dio: dio);
  }

  /// 切换 baseUrl / 拦截器等配置时重新初始化。
  void reinit(HttpClientConfig config, {Dio? dio}) {
    _applyConfig(config, dio: dio);
  }

  void _applyConfig(HttpClientConfig config, {Dio? dio}) {
    _config = config;
    _dio = dio ?? Dio(_createBaseOptions(config));
    _dio!
      ..options = _createBaseOptions(config)
      ..interceptors.clear();

    final headerProvider = config.headerProvider;
    if (headerProvider != null) {
      _dio!.interceptors.add(HeaderInterceptor(headerProvider));
    }

    final responseHook = config.responseHook;
    if (responseHook != null) {
      _dio!.interceptors.add(RspInterceptor(responseHook));
    }

    _dio!.interceptors.addAll(config.interceptors);

    if (config.maxRetries > 0) {
      _dio!.interceptors.add(
        RetryInterceptor(dio: _dio!, maxRetries: config.maxRetries),
      );
    }

    if (config.enableLog) {
      _dio!.interceptors.add(LogPrintInterceptor(logger: config.logger));
    }
  }

  void addInterceptor(Interceptor interceptor) {
    _requireDio().interceptors.add(interceptor);
  }

  void setHeader(String key, dynamic value) {
    _requireDio().options.headers[key] = value;
  }

  void removeHeader(String key) {
    _requireDio().options.headers.remove(key);
  }

  void clearHeaders() {
    _requireDio().options.headers.clear();
  }

  Future<HttpResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    JsonConverter<T>? converter,
  }) {
    return request<T>(
      path,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      converter: converter,
    );
  }

  Future<HttpResult<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    JsonConverter<T>? converter,
  }) {
    return request<T>(
      path,
      method: HttpMethod.post,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      converter: converter,
    );
  }

  Future<HttpResult<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    JsonConverter<T>? converter,
  }) {
    return request<T>(
      path,
      method: HttpMethod.put,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      converter: converter,
    );
  }

  Future<HttpResult<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    JsonConverter<T>? converter,
  }) {
    return request<T>(
      path,
      method: HttpMethod.patch,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      converter: converter,
    );
  }

  Future<HttpResult<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    JsonConverter<T>? converter,
  }) {
    return request<T>(
      path,
      method: HttpMethod.delete,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      converter: converter,
    );
  }

  Future<HttpResult<T>> request<T>(
    String path, {
    HttpMethod method = HttpMethod.get,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    JsonConverter<T>? converter,
  }) async {
    final currentDio = _requireDio();
    final currentConfig = config;

    try {
      final response = await currentDio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _withMethod(options, method),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return currentConfig.responseParser.parse<T>(
        response,
        converter: converter,
      );
    } catch (error, stackTrace) {
      final converter = currentConfig.errorConverter;
      if (converter != null) {
        throw converter.convert(error, stackTrace);
      }
      throw HttpRequestException.from(error, stackTrace);
    }
  }

  Future<Response<dynamic>> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) {
    return _requireDio().download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }

  Future<HttpResult<T>> upload<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    JsonConverter<T>? converter,
  }) {
    return post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      converter: converter,
    );
  }

  BaseOptions _createBaseOptions(HttpClientConfig config) {
    return BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: Map<String, dynamic>.of(config.headers),
      responseType: config.responseType,
      followRedirects: config.followRedirects,
      validateStatus: config.validateStatus,
    );
  }

  Options _withMethod(Options? options, HttpMethod method) {
    final requestOptions = options ?? Options();
    return requestOptions.copyWith(method: method.value);
  }

  Dio _requireDio() {
    final currentDio = _dio;
    if (currentDio == null) {
      throw StateError('HttpManager has not been initialized.');
    }
    return currentDio;
  }
}
