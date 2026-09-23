/// 支付宝客户端配置。
///
/// 拿到正式凭证后改这里，并同步：
/// 1. 根 `pubspec.yaml` → `tobias.url_scheme`
/// 2. `ios/Runner/Info.plist` → alipay 的 `CFBundleURLSchemes`
/// 3. Go `.env` → `ALIPAY_APP_ID` / `ALIPAY_PRIVATE_KEY`（服务端签单，勿放 App）
abstract final class WysAlipayConfig {
  WysAlipayConfig._();

  /// iOS 回跳 URL Scheme（禁止含 `_`；须与支付宝开放平台一致）
  static const urlScheme = 'xiaomaoalipay';

  /// 仅文档/校验用；真正下单签名在 Go 侧用 AppId + 私钥
  static const appId = '';

  static bool get isClientSchemeConfigured => urlScheme.trim().isNotEmpty;
}
