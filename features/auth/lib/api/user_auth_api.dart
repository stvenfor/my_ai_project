import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_core/core.dart';
import 'package:module_http/module_http.dart';

/// =============================================================================
/// UserAuthApi — 登录/注册 HTTP 封装
///
/// 响应格式：ResultModel { code, message, data: { token, user } }
/// _mapFailure：把 Go 中文 message 映射为 typed AuthFailure，UI 好展示
/// =============================================================================
class UserAuthApi {
  static const loginPath = '/api/v1/user/login';
  static const registerPath = '/api/v1/user/register';
  static const refreshPath = '/api/v1/user/refresh';
  static const logoutPath = '/api/v1/user/logout';
  static const sendPhoneOtpPath = '/api/v1/user/phone/otp/send';
  static const verifyPhoneOtpPath = '/api/v1/user/phone/otp/verify';

  Future<LoginResult> login({
    required String username,
    required String password,
    required String deviceId,
    required String platform,
  }) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.post<ResultModel<LoginResult>>(
        loginPath,
        data: {
          'username': username,
          'password': password,
          'device_id': deviceId,
          'platform': platform,
        },
        converter: _parseLoginResult,
      );
      final model = result.data;
      if (model == null || !model.isSuccess || model.data == null) {
        throw _mapFailure(model?.code, model?.message);
      }
      return model.data!;
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(
        int.tryParse(error.code ?? ''),
        error.message,
      );
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  Future<void> sendPhoneOtp({required String phone}) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.post<ResultModel<Object?>>(
        sendPhoneOtpPath,
        data: {'phone': phone},
        converter: _parseOkResult,
      );
      final model = result.data;
      if (model == null || !model.isSuccess) {
        throw _mapFailure(model?.code, model?.message);
      }
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(
        int.tryParse(error.code ?? ''),
        error.message,
      );
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  Future<LoginResult> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String deviceId,
    required String platform,
  }) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.post<ResultModel<LoginResult>>(
        verifyPhoneOtpPath,
        data: {
          'phone': phone,
          'otp': otp,
          'device_id': deviceId,
          'platform': platform,
        },
        converter: _parseLoginResult,
      );
      final model = result.data;
      if (model == null || !model.isSuccess || model.data == null) {
        throw _mapFailure(model?.code, model?.message);
      }
      return model.data!;
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(
        int.tryParse(error.code ?? ''),
        error.message,
      );
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  Future<RefreshTokenResult> refresh({
    required String refreshToken,
    String? deviceId,
    String? sessionId,
    String? platform,
  }) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result =
          await HttpManager.instance.post<ResultModel<RefreshTokenResult>>(
        refreshPath,
        data: {
          'refresh_token': refreshToken,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
          if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
          if (platform != null && platform.isNotEmpty) 'platform': platform,
        },
        options: Options(extra: const {'skipAuthRefresh': true}),
        converter: _parseRefreshResult,
      );
      final model = result.data;
      if (model == null || !model.isSuccess || model.data == null) {
        throw _mapFailure(model?.code, model?.message);
      }
      return model.data!;
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(
        int.tryParse(error.code ?? ''),
        error.message,
      );
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  Future<void> logout({
    required String token,
    required String sessionId,
    required String deviceId,
  }) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.post<ResultModel<Object?>>(
        logoutPath,
        options: Options(
          extra: const {'skipAuthRefresh': true},
          headers: {
            'Authorization': 'Bearer $token',
            'X-Session-ID': sessionId,
            'X-Device-ID': deviceId,
          },
        ),
        converter: _parseOkResult,
      );
      final model = result.data;
      if (model == null || !model.isSuccess) {
        throw _mapFailure(model?.code, model?.message);
      }
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(
        int.tryParse(error.code ?? ''),
        error.message,
      );
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  Future<RegisterResult> register({
    required String username,
    required String password,
    required String email,
    required String deviceId,
    required String platform,
  }) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result =
          await HttpManager.instance.post<ResultModel<RegisterResult>>(
        registerPath,
        data: {
          'username': username,
          'password': password,
          'email': email,
          'device_id': deviceId,
          'platform': platform,
        },
        converter: _parseRegisterResult,
      );
      final model = result.data;
      if (model == null || !model.isSuccess || model.data == null) {
        throw _mapFailure(model?.code, model?.message);
      }
      return model.data!;
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(
        int.tryParse(error.code ?? ''),
        error.message,
      );
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  static ResultModel<RefreshTokenResult> _parseRefreshResult(dynamic json) {
    return ResultModel.object(
      json as Map<String, dynamic>,
      RefreshTokenResult.fromJson,
    );
  }

  static ResultModel<LoginResult> _parseLoginResult(dynamic json) {
    return ResultModel.object(
      json as Map<String, dynamic>,
      LoginResult.fromJson,
    );
  }

  static ResultModel<RegisterResult> _parseRegisterResult(dynamic json) {
    return ResultModel.fromJson(
      json as Map<String, dynamic>,
      RegisterResult.fromJson,
    );
  }

  static ResultModel<Object?> _parseOkResult(dynamic json) {
    return ResultModel.fromJson(
      json as Map<String, dynamic>,
      (_) => null,
    );
  }

  AuthFailure _mapFailure(int? code, String? message) {
    final text = message?.trim() ?? '';
    if (code == 10003 ||
        text.contains('账号未注册') ||
        text.contains('请先注册')) {
      return const AccountNotRegisteredFailure();
    }
    if (code == 10002 ||
        text.contains('密码错误') ||
        text.contains('用户名或密码错误') ||
        text.contains('Unauthorized')) {
      return const InvalidCredentialsFailure();
    }
    if (text.contains('验证邮件')) {
      return const EmailConfirmationRequiredFailure();
    }
    if (text.contains('验证码错误') || text.contains('验证码已失效')) {
      return const InvalidOtpFailure();
    }
    if (text.contains('短信登录暂未开放')) {
      return UnknownAuthFailure(text);
    }
    if (text.contains('用户已存在')) {
      return const EmailAlreadyRegisteredFailure();
    }
    if (text.contains('参数错误') || text.contains('password')) {
      return const WeakPasswordFailure();
    }
    if (text.contains('无法连接 Supabase') ||
        text.contains('Supabase 未配置') ||
        text.contains('认证服务暂时不可用')) {
      if (text.isNotEmpty) {
        return BackendServiceFailure(text);
      }
      final baseUrl = BackendHttpConfig.resolveBackendBaseUrl();
      return BackendServiceFailure(
        '认证服务暂时不可用，请检查 Go 后端 Supabase 配置（$baseUrl）',
      );
    }
    if (code == 50000 || text.contains('服务器内部错误')) {
      return UnknownAuthFailure(
        text.isNotEmpty ? text : '服务端异常，请稍后重试',
      );
    }
    if (_isConnectionFailure(text)) {
      final baseUrl = BackendHttpConfig.resolveBackendBaseUrl();
      return NetworkAuthFailure(
        '无法连接服务端（$baseUrl），请确认 my_go_study 已启动',
      );
    }
    return UnknownAuthFailure(text.isNotEmpty ? text : '登录失败，请稍后重试');
  }

  bool _isConnectionFailure(String text) {
    if (text.isEmpty) return false;
    const keywords = [
      'Connection refused',
      'Connection failed',
      'connection error',
      'connection timeout',
      'Network is unreachable',
      'Failed host lookup',
      'SocketException',
      '网络连接异常',
      '连接超时',
      '未知网络异常',
      'Software caused connection abort',
      'No route to host',
    ];
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }
}

class LoginResult {
  const LoginResult({
    required this.token,
    required this.user,
    this.refreshToken = '',
    this.sessionId = '',
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      user: BackendUser.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : const {},
      ),
    );
  }

  final String token;
  final String refreshToken;
  final String sessionId;
  final BackendUser user;
}

class RefreshTokenResult {
  const RefreshTokenResult({
    required this.token,
    required this.refreshToken,
    this.sessionId = '',
  });

  factory RefreshTokenResult.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResult(
      token: json['token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
    );
  }

  final String token;
  final String refreshToken;
  final String sessionId;
}

class RegisterResult {
  const RegisterResult({
    required this.user,
    this.token,
    this.refreshToken,
    this.sessionId,
  });

  factory RegisterResult.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const RegisterResult(user: BackendUser(id: '', username: '', email: ''));
    }
    final token = json['token']?.toString() ?? '';
    final refreshToken = json['refresh_token']?.toString() ?? '';
    final sessionId = json['session_id']?.toString() ?? '';
    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      return RegisterResult(
        token: token.isNotEmpty ? token : null,
        refreshToken: refreshToken.isNotEmpty ? refreshToken : null,
        sessionId: sessionId.isNotEmpty ? sessionId : null,
        user: BackendUser.fromJson(json['user'] as Map<String, dynamic>),
      );
    }
    return RegisterResult(
      token: token.isNotEmpty ? token : null,
      refreshToken: refreshToken.isNotEmpty ? refreshToken : null,
      sessionId: sessionId.isNotEmpty ? sessionId : null,
      user: BackendUser.fromJson(json),
    );
  }

  final String? token;
  final String? refreshToken;
  final String? sessionId;
  final BackendUser user;

  bool get hasSession => token != null && token!.isNotEmpty;
}

class BackendUser {
  const BackendUser({
    required this.id,
    required this.username,
    required this.email,
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  final String id;
  final String username;
  final String email;
}
