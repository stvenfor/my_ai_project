---
label: done
feature: auth-session
source: grill-with-docs; docs/contexts/auth-session/CONTEXT.md
adrs: 0006, 0007, 0008
test-seams: auth-service-user-service-session; auth-navigation
---

# Spec: 壳工程真实登录与 Auth Session 验收闭环

## Problem Statement

需要把「能登录服务端、登录后数据缓存、冷启动仍登录、登出可靠、业务请求带 token」的真实流程在壳工程跑通并验收。仓库里另有未接线的 `wys_account`，以及 auth 模块独立运行入口，容易让人以为登录有多套主人或多套入口；独立运行还会强制 Mock，掩盖真实联调。

## Solution

以 `module_auth` 为唯一 Session Owner，经 Go BFF 做邮箱密码登录/注册，本地持久化 Auth Session。产品上只有壳工程 Login Gate；摘掉 auth 独立运行登录能力。邀请登录统一 `AuthNavigation.openLogin`，失效/登出后强制清栈回登录。冷启动刷新失败保留本地会话；真实登出需服务端确认（会话已不存在视为成功）；Mock 仍本地清。联调关闭邮箱验证。`wys_account` 本轮不动。

## User Stories

1. As a 用户, I want 在壳工程用邮箱和密码登录 Go 后端, so that 我拿到真实 access token 而不是 Mock。
2. As a 用户, I want 登录成功后进入主页, so that 我能继续使用 App。
3. As a 用户, I want 「我的」页看到当前用户展示信息, so that 我确认已登录。
4. As a 用户, I want 杀掉进程再打开后仍保持已登录, so that Auth Session 缓存真正生效。
5. As a 用户, I want 冷启动时即使静默刷新失败也不被踢去登录, so that 网络抖动不会毁掉本地会话。
6. As a 用户, I want 登录后打开任一需登录业务（如二手车或数据分析）能正常请求, so that Authorization 等头已带上。
7. As a 用户, I want 从未登录点需登录功能时被带到统一登录门, so that 我知道要先登录。
8. As a 用户, I want 登录成功后能回到原先想去的页面（若有回跳）, so that 我不必重新找入口。
9. As a 新用户, I want 在壳工程注册并立刻处于已登录, so that 注册即会话、无需再登一次（除非需邮箱验证——联调环境已关闭）。
10. As a 用户, I want 注册时若邮箱已存在则看到明确提示并停在注册页, so that 我不会被静默改成登录或写坏会话。
11. As a 用户, I want 主动登出时服务端确认成功后本地会话被清除并回到登录页, so that 我无法返回已登录主页。
12. As a 用户, I want 登出时若服务端说会话已不存在则本地仍被清除, so that 我不会卡在无效会话里。
13. As a 用户, I want 登出时若网络失败则仍保持登录并看到错误提示, so that 服务端会话还在时本地不会单方面丢掉。
14. As a 开发者在 Mock 模式, I want 登出仍立刻清本地, so that 离线改 UI 不会卡死。
15. As a 开发者, I want `USE_MOCK_AUTH` 决定 Mock 与真实后端, so that 壳工程与配置一致、只有一个开关。
16. As a 开发者, I want auth 独立运行不再提供登录闭环, so that 产品上只有一个 Login Gate。
17. As a 开发者, I want 壳内「请登录」都走 `AuthNavigation.openLogin`, so that 不会丢 Binding 或回跳。
18. As a 开发者, I want 会话失效与登出成功后走 Force Reset Login（清栈）, so that 与邀请登录意图分离。
19. As a 开发者, I want 本轮不接线、不删除 `wys_account`, so that 范围不扩到库迁移。
20. As a 开发者, I want OTP 与「refresh 必须成功」不在本轮验收, so that 先交付邮箱密码真实闭环。
21. As a QA, I want 仅用壳工程真实界面验收（不加专用会话调试页）, so that 验收路径等于用户路径。
22. As a QA, I want 联调环境关闭邮箱验证且 Go 已启动、`USE_MOCK_AUTH=false`, so that 注册与登录能写入会话。

## Implementation Decisions

- Session Owner 为 `module_auth`（`UserService` / `AuthLifecycle` / `module_http` 头注入）；不把真实流程迁到 `wys_account`（ADR 0006）。
- 登录/注册 UI 仍在 `features/auth`；仅壳工程可作为产品登录入口（ADR 0007）。
- Remove：auth `main_dev` / 独立运行不再进入登录注册闭环；去掉 `standaloneMode` → 开发成功页作为登录后落点；壳内登录成功进主页（可带回跳）。
- Mock vs 真实：只认 `USE_MOCK_AUTH`；独立运行若保留入口也不得再强制 `useMock: isStandalone`（本轮以摘掉登录入口为主）。
- Cold Start Keep：启动静默 refresh 失败不得清除本地 Auth Session（ADR 0008）；调整 `BackendAuthService.refreshSession`（及任何同等清会话路径）以符合此规则。
- Server-Confirmed Logout + Gone：真实 `signOut` 仅在服务端成功或会话已不存在时清本地；网络/拒绝则提示并保持登录；Mock `signOut` 仍本地清（ADR 0008）。
- Registration Session：注册成功以本地已有会话为准；已存在邮箱 Stay 在注册页；联调关闭邮箱验证。
- OneCall + SplitNav：邀请登录 → `AuthNavigation.openLogin`；强制回登录 → `AuthNavigation` 上的清栈 API（命名实现时自定）；收敛壳内直接 `Get.toNamed(RoutePath.login)` 的邀请路径；`components/linking` 等只读登录态处同步改邀请路径。
- 业务 token 证明：任一需登录且走 Go 的功能即可（Either），不钉死单一菜单。
- 本轮不改 Go 登录/注册 API 契约；不新增第二套会话存储。

## Testing Decisions

- 只测外部行为：会话是否存在、失败是否清会话、导航意图（邀请 vs 强制），不测实现细节与像素。
- **主缝 `auth-service-user-service-session`**：`AuthService` + `UserService`（及登出策略）覆盖登录/注册落盘、Keep、Server/Gone/MockLocal 登出。优先单测或会话级测试；可对 HTTP 打桩。
- **导航缝 `auth-navigation`**：Invite Login vs Force Reset Login 行为；壳内邀请路径不再直接点名登录路由。
- 手工验收清单：壳工程 UI（登录、注册、冷启动、「我的」、登出、任选需登录业务）；环境前提见 User Stories 22。
- Prior art：`features/auth/test/`、既有 AuthFailure 映射测试风格。

## Out of Scope

- 手机号 OTP 真实打通与验收
- access token 过期后 refresh「必须成功」的验收（失败保留本地已在范围内）
- `wys_account` 接线、废弃标或删除
- 独立模块与壳工程共享同一份本地会话
- 邮箱验证产品流程（查收邮件后再登录）
- 新建专用 Auth 调试页
- 视觉改版（非阻塞本闭环）

## Further Notes

- Glossary：`docs/contexts/auth-session/CONTEXT.md`
- ADRs：0006 Session Owner；0007 Shell-only Login Gate；0008 Cold Start Keep + Server-Confirmed Logout
- Tracker：`.scratch/auth-session/`（本地 markdown）；票见 `issues/01`–`06`，frontier：01、02、04、05
- 环境：Go `my_go_study` 可达；`.env` 中 `USE_MOCK_AUTH=false`；Supabase 邮箱验证关闭
