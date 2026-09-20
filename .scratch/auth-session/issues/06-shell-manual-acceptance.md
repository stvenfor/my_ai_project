# 06 — 壳工程手工验收闭环

**What to build:** 在壳工程用真实界面跑通 SPEC 验收：邮箱登录、注册即会话、冷启动仍登录、「我的」可见用户、登出（Server/Gone）、任选一条需登录业务证明请求带 token。环境：Go 可达、`USE_MOCK_AUTH=false`、Supabase 邮箱验证关闭。

**Blocked by:** 01 — Cold Start Keep；02 — Server-Confirmed Logout；03 — AuthNavigation；04 — 摘掉独立运行登录；05 — Registration Session

**Status:** done

## 环境预检

- [x] `.env` 中 `USE_MOCK_AUTH=false`
- [x] Go 可达；register/login/logout 接口正常
- [x] 票 01–05 代码已合入；auth 测试全绿
- [x] auth 独立运行非登录门；未接线 `wys_account`

## 壳工程 UI 点验（人工确认 2026-09-20）

- [x] 壳工程邮箱登录成功进主页，「我的」显示当前用户（`qa_user`）
- [x] 新邮箱注册后本地已登录（In）/ 或等价用已注册账号完成登录态验收
- [x] 杀进程再开仍已登录（Keep）
- [x] 登出符合 Server/Gone；无法返回已登录主页
- [x] 任选需登录业务可请求 Go（Either）
- [x] 未使用 auth 独立运行作为登录入口；未依赖 wys_account
