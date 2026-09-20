# 06 — 壳工程手工验收闭环

**What to build:** 在壳工程用真实界面跑通 SPEC 验收：邮箱登录、注册即会话、冷启动仍登录、「我的」可见用户、登出（Server/Gone）、任选一条需登录业务证明请求带 token。环境：Go 可达、`USE_MOCK_AUTH=false`、Supabase 邮箱验证关闭。

**Blocked by:** 01 — Cold Start Keep；02 — Server-Confirmed Logout；03 — AuthNavigation；04 — 摘掉独立运行登录；05 — Registration Session

**Status:** ready-for-agent — 环境已就绪，待壳工程 UI 点验

## 环境预检（已代跑）

- [x] `.env` 中 `USE_MOCK_AUTH=false`
- [x] Go `http://127.0.0.1:8080/health` → `{"status":"ok"}`
- [x] `POST /api/v1/user/register` 成功且响应带 token（Registration Session / 邮箱验证已关）
- [x] `POST /api/v1/user/login` / `logout` 成功
- [x] 票 01–05 代码已合入；`flutter test features/auth/test/` 全绿
- [x] auth 独立运行仅为占位页（非登录门）；未接线 `wys_account`

## 壳工程 UI 点验步骤

启动（模拟器，本机 Go）：

```bash
./scripts/run_app.sh -d DCA54F0C-8624-4BF6-9E42-539C4A5E1063
# 或：./scripts/run_app.sh   # 按脚本选设备；模拟器用 .env，真机用 .env.lan
```

可用已注册账号（接口探测创建，仅本地 QA）：

- 邮箱：`auth_session_qa_1789898320@example.com`
- 密码：`TestPass123`

也可在 App 内用**新邮箱**再验一遍注册（In）。

### 清单

- [ ] **登录**：壳工程打开登录门 → 邮箱密码登录 → 进主页 →「我的」显示当前用户（非访客）
- [ ] **注册（可选再验）**：新邮箱注册后本地已登录，无需再登一次
- [ ] **冷启动**：杀进程再开仍已登录（「我的」仍是该用户）
- [ ] **登出**：登出成功回登录门；返回键回不到已登录主页；断网再登出应提示且保持登录（Server）
- [ ] **业务 token**：登录后打开二手车或数据分析任一，能请求 Go（非未授权踢回登录）
- [ ] **入口**：全程只用壳工程登录；未跑 `./scripts/run_module.sh auth` 当登录入口

全部勾完后把本票 **Status** 改为 `done`。
