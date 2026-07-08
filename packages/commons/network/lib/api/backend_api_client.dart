import 'package:dio/dio.dart';
import 'package:module_http/api/backend_api_models.dart';
import 'package:module_http/http/auth_header_provider.dart';
import 'package:module_http/http/backend_http_config.dart';
import 'package:module_http/http/http.dart';
import 'package:module_http/http/my_interceptor.dart';

/// 对接 Go 后端 my_go_study（/api/v1），自动携带 Supabase JWT。
class BackendApiClient {
  BackendApiClient({
    Dio? dio,
    AuthHeaderProvider? headerProvider,
    String? baseUrl,
  }) : _dio = dio ??
            _createDio(
              headerProvider: headerProvider ?? const AuthHeaderProvider(),
              baseUrl: baseUrl ?? BackendHttpConfig.resolveBackendBaseUrl(),
            );

  final Dio _dio;

  static const profilePath = '/api/v1/me/profile';
  static const transactionsPath = '/api/v1/transactions';

  static Dio _createDio({
    required AuthHeaderProvider headerProvider,
    required String baseUrl,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          Headers.acceptHeader: Headers.jsonContentType,
          Headers.contentTypeHeader: Headers.jsonContentType,
        },
      ),
    );
    dio.interceptors.add(HeaderInterceptor(headerProvider));
    return dio;
  }

  Future<BackendProfile> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>(profilePath);
    return BackendProfile.fromJson(_expectMap(response));
  }

  Future<BackendProfile> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      profilePath,
      data: {
        if (displayName != null) 'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );
    return BackendProfile.fromJson(_expectMap(response));
  }

  Future<List<BackendTransaction>> listTransactions({
    String? type,
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      transactionsPath,
      queryParameters: {
        if (type != null && type.isNotEmpty) 'type': type,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    return BackendTransactionList.fromJson(_expectMap(response)).items;
  }

  Future<BackendTransaction> getTransaction(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('$transactionsPath/$id');
    return BackendTransaction.fromJson(_expectMap(response));
  }

  Future<BackendTransaction> createTransaction({
    required String type,
    required String category,
    required double amount,
    required String date,
    String? note,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      transactionsPath,
      data: {
        'type': type,
        'category': category,
        'amount': amount,
        'date': date,
        if (note != null) 'note': note,
      },
    );
    return BackendTransaction.fromJson(_expectMap(response));
  }

  Future<BackendTransaction> updateTransaction(
    int id, {
    String? type,
    String? category,
    double? amount,
    String? date,
    String? note,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '$transactionsPath/$id',
      data: {
        if (type != null) 'type': type,
        if (category != null) 'category': category,
        if (amount != null) 'amount': amount,
        if (date != null) 'date': date,
        if (note != null) 'note': note,
      },
    );
    return BackendTransaction.fromJson(_expectMap(response));
  }

  Future<void> deleteTransaction(int id) async {
    await _dio.delete<void>('$transactionsPath/$id');
  }

  Map<String, dynamic> _expectMap(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) {
      throw HttpRequestException(message: '后端返回空响应', statusCode: response.statusCode);
    }
    final error = data['error'];
    if (error is String && error.isNotEmpty) {
      throw HttpRequestException(message: error, statusCode: response.statusCode);
    }
    return data;
  }
}
