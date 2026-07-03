import 'package:module_core/env/app_env.dart';

/// Supabase 配置（通过 --dart-define 或 --dart-define-from-file=.env 注入）。
class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// 为 true 时使用 Mock 认证（auth 模块独立运行默认开启）。
  static const useMockAuth =
      bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: false);

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// 仍为 .env.example 占位符（未注入真实配置）。
  static bool get usesPlaceholder =>
      url.contains('your-project') ||
      anonKey == 'your-anon-key' ||
      anonKey.startsWith('your-');

  /// 启动前校验；有问题时返回用户可读说明。
  static String? get configurationIssue {
    if (!isConfigured) {
      return '未加载 Supabase 配置，请使用 flutter run --dart-define-from-file=.env 启动';
    }
    if (usesPlaceholder) {
      return 'Supabase 仍为示例地址，请检查 .env 后重新运行（需完整重启，非热重载）';
    }
    if (!url.startsWith('https://') || !url.contains('.supabase.co')) {
      return 'SUPABASE_URL 格式不正确，请从 Supabase 控制台复制 Project URL';
    }
    return null;
  }

  /// 日志用：仅展示 host，不输出密钥。
  static String get urlHost {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return url;
    }
  }

  /// 单 Project 策略：Supabase 不随 [AppEnv] 切换。
  static String resolveUrl([AppEnv? _]) => url;

  static String resolveAnonKey([AppEnv? _]) => anonKey;
}
