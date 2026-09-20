# components — 可选组合能力

本目录与 `lib/`、`commons/`、`features/` **同级**，存放**按需引入**的组合能力：平台 SDK 封装、Realtime/IM、调试工具、以及未来共享 UI kit / 三方 wrapper。

## module_* / dokit（本工程主栈）

| 目录 | package name | 职责 |
|------|-------------|------|
| `realtime/` | `module_realtime` | Go BFF WebSocket Realtime |
| `linking/` | `module_linking` | 深链、推送、隐私 consent |
| `rongcloud_im/` | `module_rongcloud_im` | 融云 IM 引擎 |
| `bluetooth/` | `module_bluetooth` | BLE demo / 封装 |
| `dokit/` | `dokit` | Vendored DoKit |
| `dokit_bootstrap/` | `module_dokit_bootstrap` | Debug 壳工程 DoKit 注册 |

## wys_*

| 目录 | package name | 职责 | 与主栈关系 |
|------|-------------|------|------------|
| `wys_push/` | `wys_push` | 极光推送门面 + OHOS deeplink 插件 | 与 `module_linking` 推送域重叠，后续可合并 |
| `wys_face_verify/` | `wys_face_verify` | 腾讯云慧眼人脸核身（OHOS HAR） | 无对应；依赖 `wys_network` |
| `wys_login_share_pay/` | `wys_login_share_pay` | 微信登录/分享/支付 + 支付宝 | 与 `features/pay` UI 层互补 |

## 依赖约定

- `components → commons` 允许（含 `wys_* → wys_network`）
- **禁止** `components → features`（登录态用 `module_core` 的 `AuthLifecycle` / `UserService` / `SessionGuardService`）
- `features` / `lib` 按需 path 依赖本目录下的包
- OHOS 原生 `pluginClass`（如 `TfDeepLinkPlugin`）与 MethodChannel（`com.tf.flutter/*`）保持上游注册名，避免插件无法绑定
