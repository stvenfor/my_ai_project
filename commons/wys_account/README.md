# wys_account — DEPRECATED

**本包已废弃，请勿在新代码中初始化或依赖。**

产品 Session Owner 为 **`module_auth`**（见 [ADR 0006](../../docs/adr/0006-auth-session-owner-module-auth.md)、[ADR 0009](../../docs/adr/0009-deprecate-wys-account.md)）。

| 需求 | 使用 |
|------|------|
| 登录态 / 当前用户 | `AuthLifecycle` / `UserService`（`module_core` + `module_auth`） |
| HTTP 带 token | `module_http`（壳工程 `AppHttpBootstrap`） |
| 需登录跳转 | `AuthNavigation.openLogin` |

- **不要**调用 `WysAccount.initialize` / `WysAccount.setSession` / `WysAccount.logout`
- 包目录本轮**保留、未删除**；根工程已不再 path 依赖
- 历史示例（`wys_network` / `wys_push` README）中的 `WysAccount.*` 仅作遗留文档，勿照抄

详情见 `features/auth` 与 [Auth Session CONTEXT](../../docs/contexts/auth-session/CONTEXT.md)。
