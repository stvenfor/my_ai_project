import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:module_core/env/supabase_config.dart';
import 'package:module_core/model/auth/auth_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 将 supabase_flutter / http 异常映射为业务 [AuthFailure]。
class AuthExceptionMapper {
  AuthExceptionMapper._();

  static AuthFailure map(Object error) {
    if (error is AuthFailure) return error;

    if (error is AuthWeakPasswordException) {
      return const WeakPasswordFailure();
    }

    if (error is AuthRetryableFetchException) {
      return NetworkAuthFailure(_mapNetworkMessage(error.message));
    }

    if (error is AuthUnknownException) {
      return _mapUnknown(error);
    }

    if (error is AuthException) {
      return _mapAuthException(error);
    }

    if (error is http.ClientException) {
      return NetworkAuthFailure(_mapClientException(error));
    }

    if (error is SocketException) {
      return NetworkAuthFailure(_mapSocketMessage(error));
    }

    if (error is PostgrestException) {
      return DatabaseAuthFailure(_sanitizeMessage(error.message));
    }

    return UnknownAuthFailure(_mapGenericMessage(error.toString()));
  }

  static AuthFailure _mapUnknown(AuthUnknownException error) {
    final original = error.originalError;
    if (original is SocketException) {
      return NetworkAuthFailure(_mapSocketMessage(original));
    }
    if (original is http.ClientException) {
      return NetworkAuthFailure(_mapClientException(original));
    }
    return UnknownAuthFailure(
      _sanitizeMessage(error.message, fallback: '认证服务异常，请稍后重试'),
    );
  }

  static AuthFailure _mapAuthException(AuthException error) {
    final code = error.code?.toLowerCase();
    final message = error.message.toLowerCase();
    final status = error.statusCode?.toLowerCase();

    if ((message.isEmpty || message == 'null') && status != null) {
      return _mapOAuthErrorCode(status, error.message);
    }

    switch (code) {
      case 'invalid_credentials':
        return const InvalidCredentialsFailure();
      case 'user_already_exists':
      case 'email_exists':
        return const EmailAlreadyRegisteredFailure();
      case 'email_not_confirmed':
        return const EmailConfirmationRequiredFailure();
      case 'weak_password':
        return const WeakPasswordFailure();
      case 'validation_failed':
        if (message.contains('email')) return const InvalidEmailFailure();
        if (message.contains('phone')) return const InvalidPhoneFailure();
        break;
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
      case 'over_sms_send_rate_limit':
        return const OtpRateLimitFailure();
      case 'otp_expired':
      case 'otp_disabled':
        return const InvalidOtpFailure();
      case 'signup_disabled':
        return const SignUpDisabledFailure();
      case 'unexpected_failure':
        if (message.contains('database')) return const DatabaseAuthFailure();
    }

    if (message.contains('invalid login credentials')) {
      return const InvalidCredentialsFailure();
    }
    if (message.contains('user already registered') ||
        message.contains('already been registered')) {
      return const EmailAlreadyRegisteredFailure();
    }
    if (message.contains('email not confirmed')) {
      return const EmailConfirmationRequiredFailure();
    }
    if (message.contains('password') &&
        (message.contains('weak') ||
            message.contains('at least') ||
            message.contains('minimum') ||
            message.contains('too short'))) {
      return const WeakPasswordFailure();
    }
    if (message.contains('database error') ||
        message.contains('saving new user')) {
      return const DatabaseAuthFailure();
    }
    if (message.contains('unable to validate email') ||
        message.contains('invalid email')) {
      return const InvalidEmailFailure();
    }
    if (message.contains('invalid otp') ||
        message.contains('token has expired') ||
        message.contains('otp_expired')) {
      return const InvalidOtpFailure();
    }
    if (message.contains('phone') &&
        (message.contains('invalid') || message.contains('validate'))) {
      return const InvalidPhoneFailure();
    }
    if (message.contains('rate limit') ||
        message.contains('too many') ||
        message.contains('over sms send')) {
      return const OtpRateLimitFailure();
    }

    return UnknownAuthFailure(
      _sanitizeMessage(error.message, fallback: '操作失败，请稍后重试'),
    );
  }

  static AuthFailure _mapOAuthErrorCode(String errorCode, String description) {
    return switch (errorCode) {
      '4' || 'otp_expired' => const InvalidOtpFailure(),
      '8' => const WeakPasswordFailure(),
      _ => UnknownAuthFailure(
          description.isNotEmpty ? description : '认证失败，请稍后重试',
        ),
    };
  }

  static String _mapClientException(http.ClientException error) {
    return _mapNetworkMessage(error.message);
  }

  static String _mapSocketMessage(SocketException error) {
    return _mapNetworkMessage(error.message);
  }

  static String _mapNetworkMessage(String raw) {
    final text = raw.toLowerCase();

    if (text.contains('your-project.supabase.co') ||
        SupabaseConfig.usesPlaceholder) {
      return 'Supabase 地址未生效，请用 --dart-define-from-file=.env 完整重启 App';
    }

    if (text.contains('failed host lookup') ||
        text.contains('nodename nor servname') ||
        text.contains('errno = 8')) {
      return '无法连接服务器，请检查网络或 Supabase 项目地址是否正确';
    }

    if (text.contains('connection refused') ||
        text.contains('connection timed out') ||
        text.contains('network is unreachable')) {
      return '网络连接失败，请检查网络后重试';
    }

    if (text.contains('certificate') || text.contains('ssl')) {
      return '安全连接失败，请检查系统时间与网络环境';
    }

    return '网络异常，请稍后重试';
  }

  static String _mapGenericMessage(String raw) {
    if (raw.contains('ClientException') || raw.contains('SocketException')) {
      return _mapNetworkMessage(raw);
    }
    return _sanitizeMessage(raw);
  }

  static String _sanitizeMessage(String raw, {String fallback = '操作失败，请稍后重试'}) {
    final text = raw.trim();
    if (text.isEmpty || text == 'null') return fallback;
    return text;
  }
}
