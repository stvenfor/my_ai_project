/// 认证业务异常，由 Supabase 实现层映射，UI 层只处理此类型。
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('密码错误');
}

class AccountNotRegisteredFailure extends AuthFailure {
  const AccountNotRegisteredFailure() : super('账号未注册，请先注册');
}

class EmailAlreadyRegisteredFailure extends AuthFailure {
  const EmailAlreadyRegisteredFailure() : super('该邮箱已注册');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('密码至少 6 位');
}

class SignUpDisabledFailure extends AuthFailure {
  const SignUpDisabledFailure() : super('当前未开放注册');
}

class DatabaseAuthFailure extends AuthFailure {
  const DatabaseAuthFailure([
    super.message = '用户资料初始化失败，请确认已执行 supabase/migrations SQL',
  ]);
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure() : super('请输入有效的邮箱');
}

class InvalidPhoneFailure extends AuthFailure {
  const InvalidPhoneFailure() : super('请输入有效的手机号');
}

class InvalidOtpFailure extends AuthFailure {
  const InvalidOtpFailure() : super('验证码错误或已失效');
}

class EmailConfirmationRequiredFailure extends AuthFailure {
  const EmailConfirmationRequiredFailure()
      : super('注册成功，请查收验证邮件后再登录');
}

class OtpRateLimitFailure extends AuthFailure {
  const OtpRateLimitFailure() : super('发送过于频繁，请稍后再试');
}

class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure([super.message = '网络异常，请稍后重试']);
}

class SupabaseConfigFailure extends AuthFailure {
  const SupabaseConfigFailure([super.message = 'Supabase 未正确配置']);
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([super.message = '登录失败，请稍后重试']);
}
