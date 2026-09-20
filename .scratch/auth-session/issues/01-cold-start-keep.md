# 01 — Cold Start Keep（刷新失败保留会话）

**What to build:** 进程重启后以本地 Auth Session 为准恢复已登录。启动时静默刷新失败（网络、超时、接口错误）不得清除本地会话；用户仍保持已登录，可稍后重试业务请求。

**Blocked by:** None — can start immediately

**Status:** done

- [x] 真实模式下，refresh 失败后 `UserService` 仍保留原会话（不清 token）
- [x] 主缝自动化覆盖「refresh 失败 → 会话仍在」
- [x] 不把「refresh 必须成功」列为通过条件
