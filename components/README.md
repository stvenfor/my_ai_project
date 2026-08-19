# components — 可选组合能力

本目录与 `lib/`、`commons/`、`features/` **同级**，存放**按需引入**的组合能力：平台 SDK 封装、Realtime/IM、调试工具、以及未来共享 UI kit / 三方 wrapper。

| 目录 | package name | 职责 |
|------|-------------|------|
| `realtime/` | `module_realtime` | Go BFF WebSocket Realtime |
| `linking/` | `module_linking` | 深链、推送、隐私 consent |
| `rongcloud_im/` | `module_rongcloud_im` | 融云 IM 引擎 |
| `bluetooth/` | `module_bluetooth` | BLE demo / 封装 |
| `dokit/` | `dokit` | Vendored DoKit |
| `dokit_bootstrap/` | `module_dokit_bootstrap` | Debug 壳工程 DoKit 注册 |

## 依赖约定

- `components → commons` 允许
- **禁止** `components → features`（登录态用 `module_core` 的 `AuthLifecycle` / `UserService` / `SessionGuardService`）
- `features` / `lib` 按需 path 依赖本目录下的包
