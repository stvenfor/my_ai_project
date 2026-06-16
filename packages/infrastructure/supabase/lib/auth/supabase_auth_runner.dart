import 'package:module_core/model/auth/auth_failure.dart';
import 'package:module_supabase/auth/auth_exception_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 统一封装 supabase_flutter [GoTrueClient] 调用与异常映射。
class SupabaseAuthRunner {
  SupabaseAuthRunner(this._auth, {this.onAuthenticated});

  final GoTrueClient _auth;
  final Future<void> Function()? onAuthenticated;

  GoTrueClient get auth => _auth;

  Future<T> run<T>(Future<T> Function(GoTrueClient auth) action) async {
    try {
      final result = await action(_auth);
      if (onAuthenticated != null) {
        try {
          await onAuthenticated!();
        } catch (_) {
          // 认证已成功，profile 同步失败不阻断登录/注册
        }
      }
      return result;
    } catch (error) {
      throw AuthExceptionMapper.map(error);
    }
  }

  /// 校验 [signUp] 响应：session 存在即登录成功；否则区分已注册 / 待验证邮箱。
  void assertSignUpSucceeded(AuthResponse response) {
    if (response.session != null) return;

    final user = response.user;
    if (user == null) {
      throw const UnknownAuthFailure('注册失败，请稍后重试');
    }

    // Supabase 防枚举：重复注册时 identities 为空
    if (user.identities == null || user.identities!.isEmpty) {
      throw const EmailAlreadyRegisteredFailure();
    }

    throw const EmailConfirmationRequiredFailure();
  }
}
