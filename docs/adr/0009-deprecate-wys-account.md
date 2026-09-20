# 废弃 commons/wys_account（本轮不删包）

ADR 0006 将 Session Owner 定为 `module_auth`，并对 `wys_account` 采取「保留不动、不接线」的 Leave 立场。本轮**升级为废弃**：包目录仍保留（避免大迁移），但根工程不再依赖；新代码不得初始化 `WysAccount`。Session Owner 仍为 `module_auth`（`UserService` / `AuthLifecycle` / `module_http` 头注入）。删除包目录留待后续清理轮次。
