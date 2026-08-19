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

  /// 极光尚未建应用时保持 mock，不调用原生 SDK。
  static const mockPush = true;

  /// 关闭 Deeplink / Universal Link（iOS 需 Apple 侧配置，开发阶段先关）。
  static const enableDeeplink = false;

  /// dev / prod 区分 AppKey（占位，控制台创建后替换）。
  static String jpushAppKey(AppEnv env) => switch (env) {
        AppEnv.production => 'PROD_JPUSH_APP_KEY_PLACEHOLDER',
        _ => 'DEV_JPUSH_APP_KEY_PLACEHOLDER',
      };

  /// iOS APNs p8 相关配置占位（TeamId / KeyId / BundleId）。
  static const apnsTeamId = 'TEAM_ID_PLACEHOLDER';
  static const apnsKeyId = 'KEY_ID_PLACEHOLDER';
  static const apnsBundleId = 'com.sample.moduleSample';

  /// Android 厂商通道占位（华为/小米/OPPO/vivo 等，后续接入）。
  static const androidVendorChannelsEnabled = false;
}
