/// 应用运行环境（测试 / 预发 / 线上）。
///
/// **不要**用 Flutter debug/release 包区分环境；用编译宏：
/// - `--dart-define=APP_ENV=test|staging|production`
/// - 或 `--dart-define=TF_NET_TEST=true` / `TF_NET_PRODUCT=true`
enum AppEnv {
  test,
  staging,
  production;

  String get label => switch (this) {
        AppEnv.test => '测试',
        AppEnv.staging => '预发',
        AppEnv.production => '线上',
      };

  static AppEnv fromKey(String? raw) {
    return AppEnv.values.firstWhere(
      (env) => env.name == raw,
      orElse: () => AppEnv.test,
    );
  }

  /// 编译期宏解析；无宏时返回 null（交给运行时切换 / 本地持久化）。
  static AppEnv? fromCompileDefines() {
    const appEnv = String.fromEnvironment('APP_ENV', defaultValue: '');
    if (appEnv.trim().isNotEmpty) {
      return fromKey(appEnv.trim());
    }
    const product = bool.fromEnvironment('TF_NET_PRODUCT');
    if (product) return AppEnv.production;
    const test = bool.fromEnvironment('TF_NET_TEST');
    if (test) return AppEnv.test;
    return null;
  }

  /// 是否由编译宏锁定环境（正式包不应再切测试域）。
  static bool get isCompileEnvLocked => fromCompileDefines() != null;
}
