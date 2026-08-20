import 'wys_api_hosts.dart';
import 'wys_net_environment_store.dart';
import 'wys_network_config.dart';

enum AppEnv { debug, release }

/// 与 iOS `ENVIRONMENT_NET`（见 `TFTestBall.m` / `WysBaseUrlAlertController`）。
enum WysNetEnvironment {
  dev,
  test,
  product,

  /// 其它 URL（iOS `ENVIRONMENT_NET_CUSTOM`）
  custom,
}

class AppEnvironment {
  AppEnvironment._internal(this.env, this.baseUrl, this.netEnvironment);

  static late AppEnvironment _instance;
  static AppEnvironment get instance => _instance;

  final AppEnv env;
  final String baseUrl;
  final WysNetEnvironment netEnvironment;

  bool get isDebug => env == AppEnv.debug;

  /// 启动：读 `enviromentKey` + 可选 dart-define 宏（与 iOS `+[TFTestBall env]`）。
  static Future<void> bootstrap(AppEnv env) async {
    WysNetEnvironment net;
    const hasProductMacro = bool.fromEnvironment('TF_NET_PRODUCT');
    const hasTestMacro = bool.fromEnvironment('TF_NET_TEST');
    if (hasProductMacro) {
      net = WysNetEnvironment.product;
    } else if (hasTestMacro) {
      net = WysNetEnvironment.test;
    } else {
      net = await WysNetEnvironmentStore.loadSavedEnvironment();
    }
    final url = await WysNetEnvironmentStore.resolveBaseUrl(net);
    _instance = AppEnvironment._internal(env, url, net);
    WysNetworkConfig.baseUrl = url;
  }

  /// 同步初始化（不读磁盘）；混编或单测用。
  static void initialize(
    AppEnv env, {
    WysNetEnvironment? netEnvironment,
    String? baseUrl,
  }) {
    final net = netEnvironment ??
        switch (env) {
          AppEnv.debug => WysNetEnvironment.test,
          AppEnv.release => WysNetEnvironment.product,
        };
    final url = baseUrl ?? _urlFor(net);
    _instance = AppEnvironment._internal(env, url, net);
    WysNetworkConfig.baseUrl = url;
  }

  static void applyRuntime({
    required WysNetEnvironment netEnvironment,
    required String baseUrl,
  }) {
    _instance = AppEnvironment._internal(
      _instance.env,
      baseUrl,
      netEnvironment,
    );
    WysNetworkConfig.baseUrl = baseUrl;
  }

  static String _urlFor(WysNetEnvironment net) => switch (net) {
        WysNetEnvironment.dev => WysApiHosts.dev,
        WysNetEnvironment.test => WysApiHosts.test,
        WysNetEnvironment.product => WysApiHosts.product,
        WysNetEnvironment.custom => WysApiHosts.test,
      };
}