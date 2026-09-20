# 04 — 摘掉 auth 独立运行登录入口（Remove）

**What to build:** auth 模块独立运行不再提供登录/注册闭环；产品 Login Gate 只剩壳工程。登录/注册 UI 仍留在 `features/auth` 供壳打开。去掉独立运行登录成功落到开发成功页的路径。

**Blocked by:** None — can start immediately

**Status:** done

- [x] 独立运行入口无法再完成真实或 Mock 登录写会话的产品路径
- [x] 壳工程仍可通过 `features/auth` 路由打开登录/注册
- [x] `standaloneMode` → 开发成功页不再作为登录后落点
- [x] 文档/脚本提示与「仅壳工程登录」一致（若有误导文案则改）
