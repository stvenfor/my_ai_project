/// 应用运行环境
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
}
