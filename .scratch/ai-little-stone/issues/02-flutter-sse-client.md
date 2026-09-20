# 02 — Flutter：SseClient + 解析器

**What to build:** App 侧具备与 JSON `HttpManager.request` 分离的 SSE 消费能力：给定字节流，能解析出结构化事件（含 keepalive 忽略），并支持取消。本票不交付完整助手 UI。

**Blocked by:** None — can start immediately

**Status:** ready-for-agent

- [x] 可通过 Dio 流式请求（覆盖 Accept、长/零 receiveTimeout、Bearer 仍走现有鉴权头）打开 SSE
- [x] 行协议解析产出 `meta` / `delta` / `done` / `error` 等事件；注释 keepalive 被忽略
- [x] CancelToken（或等价）可中止消费
- [x] 流前非 event-stream / 4xx JSON error 可映射为明确失败
- [x] 解析器有单测（多帧、残缺行、keepalive）
