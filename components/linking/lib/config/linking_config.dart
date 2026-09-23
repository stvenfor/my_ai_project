import 'package:module_core/env/app_env.dart';

/// Deeplink / Push 全局配置。
class LinkingConfig {
  LinkingConfig._();

  /// 生产 Universal Link 域名。
  static const productionHost = 'xiaomaomain.com';

  /// Custom Scheme 兜底。
  static const customScheme = 'xiaomao';

  /// App 内路由前缀。
  static const appPathPrefix = '/app';

  /// 强制 Mock（true）时不调原生 SDK。
  /// 为 false 时若 AppKey 仍是占位，仍会走 Mock（见 [useMockPush]）。
  static const mockPush = false;

  /// 开启 Deeplink 监听（custom scheme 可用；Universal Link 需 Apple 侧配置，见遗留清单）。
  static const enableDeeplink = true;

  /// 是否实际使用 Mock 推送。
  static bool useMockPush({required bool jpushAppKeyConfigured}) {
    if (mockPush) return true;
    return !jpushAppKeyConfigured;
  }

  /// 深链 MethodChannel（与 wys_push OHOS 插件一致）。
  static const deepLinkChannel = 'com.xiaomao.flutter/deeplink';

  /// dev / prod 区分 AppKey（占位，控制台创建后替换；与 wys_push PushConfig 对齐）。
  static String jpushAppKey(AppEnv env) => switch (env) {
        AppEnv.production => 'PROD_JPUSH_APP_KEY_PLACEHOLDER',
        _ => 'DEV_JPUSH_APP_KEY_PLACEHOLDER',
      };

  static bool isJpushAppKeyConfigured(AppEnv env) {
    final key = jpushAppKey(env).trim();
    if (key.isEmpty) return false;
    return !key.toUpperCase().contains('PLACEHOLDER');
  }

  /// iOS APNs p8 相关配置占位（TeamId / KeyId / BundleId）。
  static const apnsTeamId = 'TEAM_ID_PLACEHOLDER';
  static const apnsKeyId = 'KEY_ID_PLACEHOLDER';
  static const apnsBundleId = 'com.sample.moduleSample';

  /// Android 厂商通道占位（华为/小米/OPPO/vivo 等，见遗留清单）。
  static const androidVendorChannelsEnabled = false;
}
