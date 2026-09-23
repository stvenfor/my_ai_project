# wys_login_share_pay

微信登录 / 分享好友·朋友圈 / 微信支付 + 支付宝 App 支付。

SDK：`fluwx`（微信）、`tobias`（支付宝）。业务只调本包 Service；**AppSecret、商户密钥、支付宝私钥只放 Go `.env`，禁止进 Flutter。**

## 能不能真用？

| 能力 | 客户端 | 还需要 |
|------|--------|--------|
| 分享好友 / 朋友圈 | AppID + Universal Link | 开放平台绑定包名/签名、iOS UL |
| 微信登录 | AppID + UL + 拉起授权拿 `code` | Go：`WECHAT_APP_SECRET` 换 openid 发会话 |
| 微信支付 | 用服务端返回的预支付参数唤起 | 商户号 + API Key + 统一下单（Go） |
| 支付宝支付 | `orderInfo` 字符串唤起 | AppId + 应用私钥签单（Go） |

没有 key 时：客户端会提示「未配置」；Go 接口返回 503 说明缺哪项环境变量。填齐后无需改业务代码。

## 只填这些（对照清单）

### Flutter（本包 + 壳工程）

| 位置 | 字段 |
|------|------|
| `lib/src/wys_wechat_config.dart` | `appId`、`universalLink` |
| `lib/src/wys_alipay_config.dart` | `urlScheme`（一般不用改）、可选 `appId` 备忘 |
| 根 `pubspec.yaml` | `fluwx.app_id`、`fluwx.ios.universal_link`、`tobias.url_scheme` |
| `ios/Runner/Info.plist` | weixin / alipay 的 `CFBundleURLSchemes` |
| 微信开放平台控制台 | Android 包名 + 签名；iOS Bundle ID + UL |
| 支付宝开放平台 | 应用与 `url_scheme` 一致 |

### Go（`my_go_study` `.env`）

```bash
WECHAT_APP_ID=
WECHAT_APP_SECRET=
WECHAT_MCH_ID=
WECHAT_MCH_API_KEY=
WECHAT_MCH_NOTIFY_URL=https://your.domain/api/v1/payments/wechat/notify
ALIPAY_APP_ID=
ALIPAY_PRIVATE_KEY=   # PKCS8 PEM，一行可用 \n 转义
ALIPAY_NOTIFY_URL=https://your.domain/api/v1/payments/alipay/notify
```

`WECHAT_APP_ID` 必须与 Flutter `WysWechatConfig.appId` 一致。

## API（Go）

- `POST /api/v1/user/wechat/login` `{ code, device_id, platform }` — 微信登录
- `POST /api/v1/payments/prepay`（需登录）`{ channel, amount_fen, subject }` — `wechat` / `alipay`

## 用法摘要

```dart
await WysWechatService.instance.init(); // App 启动时

// 登录
final auth = await WysWechatService.instance.authorize();
// auth.authCode → 交给 Go /user/wechat/login

// 分享
await WysWechatService.instance.shareWebpage(
  title: '标题',
  description: '摘要',
  webpageUrl: 'https://example.com',
  scene: WysWechatScene.session, // 或 timeline
);

// 支付（params 来自 Go prepay）
await WysLoginSharePayService.instance.pay(
  method: WysPaymentMethod.wechat, // 或 alipay
  params: serverMap,
);
```
