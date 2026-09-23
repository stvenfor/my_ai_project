/// 微信开放平台客户端配置。
///
/// 拿到正式凭证后，改这里的常量，并同步：
/// 1. 根 `pubspec.yaml` → `fluwx.app_id` / `fluwx.ios.universal_link`
/// 2. `ios/Runner/Info.plist` → `CFBundleURLSchemes`（须等于 appId）
/// 3. Go `.env` → `WECHAT_APP_ID` / `WECHAT_APP_SECRET`（登录换 code）及商户字段（支付）
///
/// 详见本包 README。
abstract final class WysWechatConfig {
  WysWechatConfig._();

  /// 微信开放平台 → 移动应用 AppID（形如 wx…）
  static const appId = '';

  /// iOS Universal Link，须已备案且与 Associated Domains / 开放平台一致
  static const universalLink = '';

  static bool get isConfigured =>
      appId.trim().isNotEmpty && universalLink.trim().isNotEmpty;
}
