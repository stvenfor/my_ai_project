# 01 — Go：SSE 单轮 Mock 流（无会话）

**What to build:** 已登录用户可以对助手发起一次 completion，并在 HTTP 响应里看到流式 SSE（`meta` → `delta*` → `done`）。用 curl `-N` 即可验收打字机效果；客户端中途断开后服务端停止继续吐字。本票不做多轮 Redis 停留会话。

**Blocked by:** None — can start immediately

**Status:** ready-for-agent

- [x] `POST /api/v1/sse/completions` 在 Session Auth 下可用
- [x] 成功响应为 `text/event-stream`，含 `meta` / `delta` / `done`（流帧非 ResultModel）
- [x] Mock Provider 能按业务向导风格流式输出纯文本，并尊重请求取消
- [x] 流前鉴权/参数错误返回 JSON `{"error":"..."}`
- [x] 响应头含禁用缓冲相关设置（如 `X-Accel-Buffering: no`），且每帧 Flush
- [x] 用例缝有测试：事件序与取消行为可验证
