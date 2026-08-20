import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_response.dart';
import '../network_codes.dart';

typedef WysMockDataBuilder = dynamic Function(WysMockRequest request);

class WysMockRequest {
  const WysMockRequest({
    required this.method,
    required this.path,
    this.query,
    this.data,
  });

  final String method;
  final String path;
  final Map<String, dynamic>? query;
  final Object? data;
}

class WysMockResponse {
  const WysMockResponse({
    this.code = NetworkCodes.ok,
    this.message = 'success',
    this.data,
  });

  final int code;
  final String message;
  final dynamic data;

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'data': data,
  };
}

abstract final class WysMockManager {
  WysMockManager._();

  static const _keyEnabled = 'wys_mock_enabled';
  static const _keyUserEnabled = 'wys_mock_user_enabled';
  static const _keyApiEnabled = 'wys_mock_api_enabled';

  static const defaultEnabled = bool.fromEnvironment(
    'TF_MOCK_ENABLED',
    defaultValue: false,
  );

  static const defaultUserEnabled = bool.fromEnvironment(
    'TF_MOCK_USER',
    defaultValue: bool.fromEnvironment(
      'TF_ACCOUNT_USE_MOCK',
      defaultValue: false,
    ),
  );

  static const defaultApiEnabled = bool.fromEnvironment(
    'TF_MOCK_API',
    defaultValue: false,
  );

  static bool enabled = defaultEnabled;
  static bool userEnabled = defaultUserEnabled;
  static bool apiEnabled = defaultApiEnabled;

  static final Map<String, WysMockDataBuilder> _apiMocks =
      <String, WysMockDataBuilder>{};

  static bool get shouldMockUser => enabled && userEnabled;

  static bool get shouldMockApi => enabled && apiEnabled;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool(_keyEnabled) ?? defaultEnabled;
    userEnabled = prefs.getBool(_keyUserEnabled) ?? defaultUserEnabled;
    apiEnabled = prefs.getBool(_keyApiEnabled) ?? defaultApiEnabled;
  }

  static Future<void> configure({
    bool? mockEnabled,
    bool? mockUser,
    bool? mockApi,
    bool persist = true,
  }) async {
    if (mockEnabled != null) enabled = mockEnabled;
    if (mockUser != null) userEnabled = mockUser;
    if (mockApi != null) apiEnabled = mockApi;
    if (!persist) return;
    final prefs = await SharedPreferences.getInstance();
    if (mockEnabled != null) {
      await prefs.setBool(_keyEnabled, mockEnabled);
    }
    if (mockUser != null) {
      await prefs.setBool(_keyUserEnabled, mockUser);
    }
    if (mockApi != null) {
      await prefs.setBool(_keyApiEnabled, mockApi);
    }
  }

  static Future<void> setMockEnabled(bool value) =>
      configure(mockEnabled: value);

  static Future<void> setUserMockEnabled(bool value) =>
      configure(mockUser: value);

  static Future<void> setApiMockEnabled(bool value) =>
      configure(mockApi: value);

  static Future<void> resetLocalSwitches() async {
    enabled = defaultEnabled;
    userEnabled = defaultUserEnabled;
    apiEnabled = defaultApiEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEnabled);
    await prefs.remove(_keyUserEnabled);
    await prefs.remove(_keyApiEnabled);
  }

  static void registerApiMock(
    String method,
    String path,
    WysMockDataBuilder builder,
  ) {
    _apiMocks[_key(method, path)] = builder;
  }

  static void unregisterApiMock(String method, String path) {
    _apiMocks.remove(_key(method, path));
  }

  static void clearApiMocks() {
    _apiMocks.clear();
  }

  static ApiResponse<T>? apiResponse<T>(
    WysMockRequest request, {
    T Function(dynamic data)? dataParser,
  }) {
    final body = apiBody(request);
    if (body == null) return null;
    return ApiResponse.fromJson(body, dataParser: dataParser);
  }

  static Map<String, dynamic>? apiBody(WysMockRequest request) {
    if (!shouldMockApi) return null;
    final builder = _apiMocks[_key(request.method, request.path)];
    if (builder == null) return null;
    final value = builder(request);
    if (value is WysMockResponse) return value.toJson();
    if (value is Map<String, dynamic> && value.containsKey('code')) {
      return value;
    }
    return WysMockResponse(data: value).toJson();
  }

  static String _key(String method, String path) =>
      '${method.toUpperCase()} $path';
}
