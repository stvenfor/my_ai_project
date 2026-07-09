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

  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.post<ResultModel<LoginResult>>(
        loginPath,
        data: {
          'username': username,
          'password': password,
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

  Future<RegisterResult> register({
    required String username,
    required String password,
    required String email,
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
    if (text.contains('用户已存在')) {
      return const EmailAlreadyRegisteredFailure();
    }
    if (text.contains('参数错误') || text.contains('password')) {
      return const WeakPasswordFailure();
    }
    if (text.contains('无法连接 Supabase') ||
        text.contains('Supabase 未配置') ||
        text.contains('认证服务暂时不可用')) {
      final baseUrl = BackendHttpConfig.resolveBackendBaseUrl();
      return BackendServiceFailure(
        '认证服务暂时不可用，请确认后端已启动（$baseUrl）或稍后重试',
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
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token']?.toString() ?? '',
      user: BackendUser.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : const {},
      ),
    );
  }

  final String token;
  final BackendUser user;
}

class RegisterResult {
  const RegisterResult({
    required this.user,
    this.token,
  });

  factory RegisterResult.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const RegisterResult(user: BackendUser(id: '', username: '', email: ''));
    }
    final token = json['token']?.toString() ?? '';
    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      return RegisterResult(
        token: token.isNotEmpty ? token : null,
        user: BackendUser.fromJson(json['user'] as Map<String, dynamic>),
      );
    }
    return RegisterResult(
      token: token.isNotEmpty ? token : null,
      user: BackendUser.fromJson(json),
    );
  }

  final String? token;
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
