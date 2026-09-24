import 'package:module_http/module_http.dart';

/// module_settings 内 HTTP 初始化（my_go_study）。
/// 已初始化则不再重建，避免冲掉壳层 interceptor。
class MineHttpConfig {
  static String get baseUrl => AppHttpBootstrap.resolveBaseUrl();

  static const String transactionsPath = '/api/v1/transactions';

  static void ensureInitialized({
    bool enableLog = false,
    int maxRetries = 0,
  }) {
    if (HttpManager.instance.isInitialized) return;
    AppHttpBootstrap.initialize(
      headerProvider: const AuthHeaderProvider(),
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }

  /// 兼容旧调用；语义同 [ensureInitialized]。
  static void init({bool enableLog = false, int maxRetries = 0}) {
    ensureInitialized(enableLog: enableLog, maxRetries: maxRetries);
  }
}
