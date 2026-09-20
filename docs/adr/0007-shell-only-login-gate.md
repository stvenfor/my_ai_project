# 登录门只在壳工程；摘掉 auth 独立运行登录

产品上登录/注册只能有一个 Login Gate：壳工程打开 `features/auth` 的登录/注册 UI。auth 模块独立运行（`main_dev` / `run_module.sh auth`）不再作为可登录入口（Remove：去掉独立运行登录闭环与 `standaloneMode` → 开发成功页路径）。邀请登录统一走 `AuthNavigation.openLogin`；会话失效或登出成功后的 Force Reset Login 走清栈回登录（可同属 `AuthNavigation` 的另一方法），不用 modal 式 `openLogin` 代替。
