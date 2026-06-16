import 'package:module_core/env/supabase_config.dart';
import 'package:module_core/model/auth/auth_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 初始化 Supabase SDK（壳工程启动时调用一次）。
class SupabaseBootstrap {
  SupabaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'SUPABASE_URL / SUPABASE_ANON_KEY 未配置，'
        '请使用 --dart-define-from-file=.env 启动',
      );
    }

    final configIssue = SupabaseConfig.configurationIssue;
    if (configIssue != null) {
      throw SupabaseConfigFailure(configIssue);
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        // 避免未配置 deep link 时误解析 URI 抛出 error_code=8 等异常
        detectSessionInUri: false,
      ),
    );
    _initialized = true;
  }
}
