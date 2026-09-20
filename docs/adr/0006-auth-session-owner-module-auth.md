# Auth Session 由 module_auth 拥有，不迁到 wys_account

壳工程真实登录与本地会话已由 `module_auth`（`UserService` / `auth_user_session` / `module_http` 头注入）接线到 Go BFF。`commons/wys_account` 是未接入壳的平行会话库（绑 `wys_network`，字段也不含 refresh/session/device）。本轮及当前产品边界下，Session Owner 定为 `module_auth`；`wys_account` 保留不动、不接线，避免双缓存分叉与组件契约（`AuthLifecycle`）大迁移。
