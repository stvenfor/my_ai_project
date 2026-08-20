import 'package:shared_preferences/shared_preferences.dart';

import 'app_environment.dart';
import 'wys_api_hosts.dart';

/// 与 iOS `General.h` → `kEnvironmentKey` = `@"enviromentKey"`（拼写保持一致）。
abstract final class WysNetEnvironmentStore {
  static const prefsKey = 'enviromentKey';

  static const int valueDev = 100;
  static const int valueTest = 200;
  static const int valueProduct = 300;
  static const int valueCustom = 0;

  static const _customUrlKey = 'wys_net_custom_base_url';

  static int environmentToStoredValue(WysNetEnvironment env) => switch (env) {
        WysNetEnvironment.dev => valueDev,
        WysNetEnvironment.test => valueTest,
        WysNetEnvironment.product => valueProduct,
        WysNetEnvironment.custom => valueCustom,
      };

  static WysNetEnvironment environmentFromStoredValue(int v) => switch (v) {
        valueDev => WysNetEnvironment.dev,
        valueTest => WysNetEnvironment.test,
        valueProduct => WysNetEnvironment.product,
        _ => WysNetEnvironment.custom,
      };

  static Future<WysNetEnvironment> loadSavedEnvironment() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(prefsKey);
    if (v == null) return WysNetEnvironment.test;
    return environmentFromStoredValue(v);
  }

  static Future<String?> loadCustomBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customUrlKey);
  }

  static Future<String> resolveBaseUrl(WysNetEnvironment env) async {
    if (env == WysNetEnvironment.custom) {
      final custom = await loadCustomBaseUrl();
      if (custom != null && custom.isNotEmpty) return custom;
      return WysApiHosts.test;
    }
    return switch (env) {
      WysNetEnvironment.dev => WysApiHosts.dev,
      WysNetEnvironment.test => WysApiHosts.test,
      WysNetEnvironment.product => WysApiHosts.product,
      WysNetEnvironment.custom => WysApiHosts.test,
    };
  }

  static WysNetEnvironment environmentForUrl(String url) {
    if (url == WysApiHosts.dev) return WysNetEnvironment.dev;
    if (url == WysApiHosts.test) return WysNetEnvironment.test;
    if (url == WysApiHosts.product) return WysNetEnvironment.product;
    return WysNetEnvironment.custom;
  }

  static Future<void> persistEnvironment(
    WysNetEnvironment env, {
    String? customBaseUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefsKey, environmentToStoredValue(env));
    if (env == WysNetEnvironment.custom && customBaseUrl != null) {
      await prefs.setString(_customUrlKey, customBaseUrl);
    }
  }
}