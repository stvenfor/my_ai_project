import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'app_environment.dart';
import 'interceptor/header_interceptor.dart';
import 'interceptor/response_handler_interceptor.dart';
import 'mock/wys_mock_manager.dart';
import 'models/api_response.dart';
import 'native_auth_provider.dart';
import 'network_codes.dart';
import 'wys_network_config.dart';
import 'wys_network_error.dart';

/// 对齐 `tf-fangroup-flutter` HttpUtil / DioRequest + iOS TFNetworkManager。
class HttpsClient {
  HttpsClient._();

  static final HttpsClient instance = HttpsClient._();

  static String get domain => WysNetworkConfig.baseUrl.isNotEmpty
      ? WysNetworkConfig.baseUrl
      : AppEnvironment.instance.baseUrl;

  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final client = Dio(
      BaseOptions(
        baseUrl: domain,
        connectTimeout: WysNetworkConfig.connectTimeout,
        receiveTimeout: WysNetworkConfig.receiveTimeout,
        sendTimeout: WysNetworkConfig.sendTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        // 401 等由拦截器 / getApi 处理，对齐 iOS 不直接抛未捕获异常
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    client.interceptors.add(HeaderInterceptor());
    client.interceptors.add(ResponseHandlerInterceptor());

    if (AppEnvironment.instance.isDebug) {
      client.interceptors.add(
        LogInterceptor(
          // 登录、支付等请求包含密码、验证码、手机号和 Token。即使是
          // Debug 包也不得输出请求头、请求体或响应体。
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
          error: true,
        ),
      );
    }

    if (!kIsWeb) {
      try {
        final adapter = client.httpClientAdapter;
        if (adapter is IOHttpClientAdapter) {
          adapter.createHttpClient = () {
            final c = HttpClient();
            c.badCertificateCallback = (_, __, ___) => true;
            return c;
          };
        }
      } catch (_) {}
    }

    return client;
  }

  static void reset() {
    _dio = null;
  }

  /// 混编注入后重置 Dio（token / baseUrl 变更）
  static void applySession(NativeSession session) {
    WysNetworkConfig.baseUrl = session.url;
    WysNetworkConfig.accessToken = session.token;
    WysNetworkConfig.isStar = session.isStar;
    WysNetworkConfig.subjectId = session.subjectId;
    reset();
  }

  Future<ApiResponse<T>> getApi<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic data)? dataParser,
    Options? options,
  }) async {
    final mock = WysMockManager.apiResponse<T>(
      WysMockRequest(method: 'GET', path: path, query: query),
      dataParser: dataParser,
    );
    if (mock != null) return mock;
    try {
      final response = await dio.get<dynamic>(
        path,
        queryParameters: query,
        options: options,
      );
      return _parseResponse<T>(response, dataParser: dataParser);
    } on DioException catch (e) {
      return _apiFromDioError<T>(e);
    }
  }

  Future<ApiResponse<T>> postApi<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    T Function(dynamic data)? dataParser,
    Options? options,
  }) async {
    final mock = WysMockManager.apiResponse<T>(
      WysMockRequest(method: 'POST', path: path, query: query, data: data),
      dataParser: dataParser,
    );
    if (mock != null) return mock;
    try {
      final response = await dio.post<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
      return _parseResponse<T>(response, dataParser: dataParser);
    } on DioException catch (e) {
      return _apiFromDioError<T>(e);
    }
  }

  ApiResponse<T> _parseResponse<T>(
    Response<dynamic> response, {
    T Function(dynamic data)? dataParser,
  }) {
    if (response.statusCode == NetworkCodes.expireToken) {
      final body = response.data;
      var message = '已退出登录，请重新登录';
      if (body is Map) {
        final m = body['message']?.toString();
        if (m != null && m.isNotEmpty) message = m;
        final code = body['code'];
        if (code != null) {
          return ApiResponse.fromJson(body, dataParser: dataParser);
        }
      }
      return ApiResponse<T>(
        code: NetworkCodes.expireToken,
        message: message,
        raw: body,
      );
    }
    if (response.statusCode != null &&
        response.statusCode! >= 400 &&
        response.data is! Map) {
      return ApiResponse<T>(
        code: response.statusCode!,
        message: WysNetworkError.defaultMessage,
        raw: response.data,
      );
    }
    return parseApiResponse<T>(response, dataParser: dataParser);
  }

  ApiResponse<T> _apiFromDioError<T>(DioException e) {
    final status = e.response?.statusCode ?? NetworkCodes.notNetwork;
    final body = e.response?.data;
    if (body is Map) {
      return ApiResponse.fromJson(body);
    }
    return ApiResponse<T>(
      code: status,
      message: WysNetworkError.fromDio(e).message,
      raw: body,
    );
  }

  /// 旧 Flutter `request`：成功返回 `data`，失败返回 `null` 或 `{error, msg}` 形态由调用方处理。
  Future<dynamic> request(
    String path,
    String method, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool throwOnError = false,
  }) async {
    final mock = WysMockManager.apiBody(
      WysMockRequest(
        method: method,
        path: path,
        query: queryParameters,
        data: data,
      ),
    );
    if (mock != null) return _legacyDataFromBody(mock);
    try {
      final response = await dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      final map = response.data;
      if (map is! Map) return null;
      final code = map['code'];
      if (code == NetworkCodes.ok) {
        final d = map['data'];
        if (d == true) return <String, dynamic>{};
        if (d == false) {
          return {'error': -1, 'msg': map['message']};
        }
        if (d == 1) return <String, dynamic>{};
        return d;
      }
      if (code == NetworkCodes.invalidAuth && map['data'] == 1) {
        return {'error': -2, 'msg': '未成年未认证'};
      }
      return {
        'error': -1,
        'msg': map['message'],
        if (map.containsKey('data')) 'data': map['data'],
      };
    } on DioException catch (e) {
      if (throwOnError) rethrow;
      final err = e.error;
      if (err is WysNetworkError) return {'error': -1, 'msg': err.message};
      return null;
    }
  }

  dynamic _legacyDataFromBody(Map<String, dynamic> map) {
    final code = map['code'];
    if (code == NetworkCodes.ok) {
      final d = map['data'];
      if (d == true || d == 1) return <String, dynamic>{};
      if (d == false) {
        return {'error': -1, 'msg': map['message']};
      }
      return d;
    }
    if (code == NetworkCodes.invalidAuth && map['data'] == 1) {
      return {'error': -2, 'msg': '未成年未认证'};
    }
    return {
      'error': -1,
      'msg': map['message'],
      if (map.containsKey('data')) 'data': map['data'],
    };
  }

  Future<List<dynamic>> requestArray(
    String path,
    String method, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) async {
    final result = await request(
      path,
      method,
      queryParameters: queryParameters,
      data: data,
    );
    if (result is List) return result;
    return [];
  }

  Future<String> requestString(
    String path,
    String method, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) async {
    final result = await request(
      path,
      method,
      queryParameters: queryParameters,
      data: data,
    );
    if (result == null) return '';
    return result.toString();
  }

  Future<Response<dynamic>?> get(
    String apiUrl, {
    Map<String, dynamic>? query,
  }) async {
    final mock = WysMockManager.apiBody(
      WysMockRequest(method: 'GET', path: apiUrl, query: query),
    );
    if (mock != null) {
      return Response<dynamic>(
        data: mock,
        statusCode: 200,
        requestOptions: RequestOptions(path: apiUrl, method: 'GET'),
      );
    }
    try {
      return await dio.get(apiUrl, queryParameters: query);
    } on DioException {
      return null;
    }
  }

  Future<Response<dynamic>?> post(
    String apiUrl, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final mock = WysMockManager.apiBody(
      WysMockRequest(method: 'POST', path: apiUrl, query: query, data: data),
    );
    if (mock != null) {
      return Response<dynamic>(
        data: mock,
        statusCode: 200,
        requestOptions: RequestOptions(path: apiUrl, method: 'POST'),
      );
    }
    try {
      return await dio.post(apiUrl, data: data, queryParameters: query);
    } on DioException {
      return null;
    }
  }

  void cancelAll() {
    dio.close(force: true);
    reset();
  }
}
