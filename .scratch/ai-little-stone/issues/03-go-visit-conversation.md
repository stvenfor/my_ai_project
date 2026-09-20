# 03 — Go：停留会话（conversationId + Redis + 10 轮）

**What to build:** 同一停留页内多轮追问时，服务端记住最近对话并用于生成；首句开口才创建会话，`meta` 下发 `conversationId`；离开页后的跨次续聊不在范围。会话约 30 分钟无活动过期（滑动续期），推理上下文最多 10 轮。

**Blocked by:** 01 — Go：SSE 单轮 Mock 流（无会话）

**Status:** ready-for-agent

- [x] 首句无 `conversationId` 时创建停留会话，并在 `meta` 返回 id
- [x] 后续带合法 id 时使用 Redis 上下文（最近 10 轮）生成
- [x] 非法/过期 id 返回可恢复错误（客户端可开新会话）
- [x] 取消生成时截断/标记本轮助手内容，避免污染下一轮上下文
- [x] TTL 滑动约 30 分钟，可通过配置调整
- [x] 用例缝覆盖：多轮、过期 id、取消后上下文
