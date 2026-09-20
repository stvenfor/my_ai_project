# ADR 0005: 生成流用 SSE + 停留会话，与 Realtime WS / 融云 IM 分离

## Status

Accepted

## Context

首页「AI小石头」需要请求作用域的助手流式回复（气泡多轮、可停止）。仓库已有两条实时通道：Go BFF **Realtime WebSocket**（系统通知 / presence）与 **融云 IM**（聊天 Tab）。若混用任一通道承载生成流，会把订阅模型、心跳、消息持久化与「一次提问一段回复」缠在一起。

## Decision

1. **助手生成流**使用 **HTTP SSE**（`POST /api/v1/sse/completions`），帧协议与 Session Auth 独立于 Realtime。
2. **停留会话**（Visit Conversation）：首句开口由服务端创建 `conversationId`，Redis 短时保存上下文；离开助手页即丢弃客户端 id，不提供跨次续聊；与 IM 会话、Realtime topic **不是同一概念**。
3. **禁止**用 Realtime WS 或融云消息通道承载 token/delta 流；也禁止把助手气泡写入 RongCloud 历史。
4. Flutter 落在独立 **`module_ai`**；SSE 解析基建可在 `module_http`，不复用 `module_realtime` / `module_chat` 的连接生命周期。

## Consequences

- 需单独处理：流式超时、代理缓冲（`X-Accel-Buffering`）、CancelToken、单轮在途。
- Realtime 与 IM 的文档/排障路径保持不变；助手问题查 SSE / Redis 会话键。
- 二期若要长期聊天记录或工具跳转，在 `module_ai` + SSE 协议上扩展，而不是回流到 WS/IM。

## Considered Options

| 选项 | 未选原因 |
|------|----------|
| Realtime WS 推 delta | 多路订阅与请求作用域生成混型；重连 sync 语义不适配半截回复 |
| 融云自定义消息流 | 依赖 IM SDK、持久化与登录模型；业务向导被绑进聊天产品 |
| 普通 JSON 整包返回 | 无客服流式体验，也无法验收取消/帧协议 |
