---
label: done
feature: ai-little-stone
source: grill-with-docs session; docs/sse-streaming-design.md; docs/contexts/ai-little-stone/CONTEXT.md
adrs: 0005
test-seams: go-completion-usecase; flutter-ai-stream-facade
---

# Spec: AI 小石头（SSE 流式业务向导）

## Problem Statement

首页宫格仍显示「客户管理」且无有效跳转。用户需要一个像智能客服的入口，以业务向导身份（AI 小石头）用气泡多轮对话解答「App / 4S 店里怎么用某功能」，并在回复过程中看到流式打字效果，可中途停止。后端缺少完善的、与 Realtime WebSocket / 融云 IM 分离的 SSE 生成通道。

## Solution

将首页「客户管理」改为「AI小石头」；登录后进入独立助手页（客服式气泡 UI）。用户通过输入或快捷问发送消息；助手经 Go BFF 的 HTTP SSE 返回流式纯文本回复。服务端用停留会话（Redis 短时 + `conversationId`）支持同页多轮；离开页面即新会话。一期用 Mock Provider 做实协议，配置可切换 OpenAI 兼容实现。Flutter 新建 `module_ai`；不接入融云、不走 Realtime。

## User Stories

1. As a 已登录用户, I want 首页看到「AI小石头」而不是「客户管理」, so that 我知道这是助手入口。
2. As a 未登录用户, I want 点击「AI小石头」先被带到登录, so that 只有登录后才能使用助手。
3. As a 已登录用户, I want 登录成功后进入助手页, so that 我不必再次寻找入口。
4. As a 用户, I want 助手页呈现左右气泡对话, so that 体验像智能客服而不是单块文档。
5. As a 用户, I want 看到欢迎说明与快捷问芯片, so that 我不知道问什么时也能开口。
6. As a 用户, I want 点击快捷问后自动作为一条用户消息发送, so that 我少打字。
7. As a 用户, I want 发送后立刻出现我的气泡, so that 我确认消息已发出。
8. As a 用户, I want 助手气泡文字逐步增长（流式回复）, so that 我感到在实时生成。
9. As a 用户, I want 流式过程中能点「停止」, so that 答偏或太长时可以打断。
10. As a 用户, I want 停止后已显示的文字仍留在气泡里, so that 我不丢失已看到的内容。
11. As a 用户, I want 流式进行时不能发送下一条, so that 对话不会乱序并行。
12. As a 用户, I want 停止或结束后再发下一句, so that 我可以多轮追问。
13. As a 用户, I want 在同一页内连续追问时助手能结合前文, so that 多轮真正有用。
14. As a 用户, I want 离开助手页再进入时是全新对话, so that 隐私与「停留会话」预期一致。
15. As a 用户, I want 助手用纯文本回答, so that 阅读稳定、无半截 Markdown 闪烁。
16. As a 用户, I want 助手回答围绕本 App / 4S 能力（如二手车、登录、数据分析）, so that 它是业务向导而不是闲聊。
17. As a 用户, I want 生成失败时仍看到已生成文字和错误提示, so that 我知道发生了什么并能换个问法。
18. As a 用户, I want 401/登录失效时被引导重新登录, so that 我不会对着空白流干等。
19. As a 用户, I want 请求过频时看到明确提示, so that 我知道稍后再试。
20. As a 开发者, I want SSE 与 Realtime WS 分离, so that 通知通道与生成通道互不污染。
21. As a 开发者, I want 助手不走融云 IM, so that 业务向导不绑聊天 SDK。
22. As a 开发者, I want 首句开口才创建 conversationId（meta 下发）, so that 空进页不产生孤儿会话。
23. As a 开发者, I want Redis 停留会话 30 分钟滑动过期, so that 短时多轮可用且键会回收。
24. As a 开发者, I want 服务端上下文最多 10 轮, so that Mock/未来 LLM 成本可控。
25. As a 开发者, I want StreamProvider 可配置切换 mock / openai_compatible, so that 不改路由即可换脑子。
26. As a 开发者, I want 一期 Mock 能按关键词给出可读流式回复且可取消, so that 可验收完善 SSE。
27. As a 开发者, I want Flutter 有独立 module_ai, so that home 只负责改名与跳转。
28. As a 开发者, I want commons 提供 SseClient/解析而不含业务文案, so that 协议复用与产品解耦。
29. As a 开发者, I want 流帧不使用 ResultModel, so that 增量解析不被信封破坏。
30. As a 开发者, I want 代理关闭缓冲（如 X-Accel-Buffering）, so that 真机/反代下仍能逐块到达。
31. As a QA, I want 用 curl -N 能看到 meta/delta/done, so that 不依赖 App 也能验协议。
32. As a QA, I want 取消请求后服务端停止继续写帧, so that 停止生成可端到端验证。

## Implementation Decisions

### Product / domain

- Brand entry label: **AI小石头** (replaces 客户管理 on home feature grid).
- Persona: App / 4S **业务向导** (not general chat, not human sales).
- UI: customer-service style **bubbles**; **纯文本** Streamed Reply; client-side **快捷问** chips; no structured action buttons in assistant bubbles (phase 1).
- **Visit Conversation**: created on first user utterance; `conversationId` returned in SSE `meta`; discarded when leaving the page; no cross-visit resume.
- **Stop Generation** + **Single In-Flight** required.
- On failure: keep partial text + inline error; no mandatory retry button.
- Auth: must be logged in before entering (same pattern as used-car).

### Architecture (ADR 0005)

- Transport: HTTP SSE only for generation; Realtime WS and RongCloud IM out of band.
- Flutter: new `module_ai`; home navigates via route + login guard.
- Go: Session Auth on `POST /api/v1/sse/completions`; Redis-backed visit conversation; `StreamProvider` with `mock` default and `openai_compatible` switch.

### API contract (normative for phase 1)

- Endpoint: `POST /api/v1/sse/completions`
- Headers: Bearer + session/device; `Accept: text/event-stream`
- Body: `prompt` (required); optional `conversationId` (omit on first turn); optional `clientRequestId`; optional `options`
- Success stream events: `meta` (includes new or echoed `conversationId`) → `delta`* → `done`; mid-stream failure → `event: error`
- Pre-stream failures: JSON `{"error":"..."}` with 4xx/5xx (not ResultModel)
- Keepalive comment frames allowed (~15s)
- Response headers include no-cache and `X-Accel-Buffering: no`
- Redis: sliding TTL ~30 minutes; context window last **10** turns; cancel truncates in-flight assistant message in context

### Flutter behavior

- `SseClient` via Dio `ResponseType.stream` (not `HttpManager.request` JSON path); override Accept; long/zero receive timeout; CancelToken on stop/dispose.
- Page: GetView + Obx; message list; disable send while streaming; stop control visible while streaming.
- Leave page: clear local `conversationId` and in-memory bubbles (new visit next time).

### Go behavior

- Implicit create on first completion without `conversationId`; unknown/expired id → clear client-recoverable error.
- Mock provider: intent/keyword style answers for app guidance; slow token simulation; respects cancel.
- Rate limit per user; clamp prompt size / max tokens.
- Config block `sse.*` (enabled, provider, ttl, maxTurns, keepalive, timeouts, openai stub settings).

### Testing seams (agreed)

1. **Go Completion usecase boundary**: authenticated completion request → observable SSE event sequence (fake provider).
2. **Flutter AI stream facade**: fake SSE/events → observable bubble list, conversation id, streaming/stop/error, single in-flight.

Home rename + login navigation: thin manual/acceptance check, not a third deep seam.

## Testing Decisions

- Good tests assert **external behavior** (frames, UI-facing state), not Redis key strings or Dio internals.
- Go: table-driven tests around completion stream ordering, cancel, bad conversation id, and mock intents; httptest optional for controller flush.
- Flutter: unit tests for SSE line parser; controller/repository tests with fake event stream (prior art: GetX + fake repos in home/settings).
- Do not require golden screenshots; do not call real OpenAI in CI.
- Manual: curl `-N`; stop button; leave-and-reenter new session; LAN device if available.

## Out of Scope

- Long-term chat history / cross-day resume
- Markdown or rich cards / server-driven navigation actions
- Regenerating a completed reply
- Parallel multi-bubble generation
- Anonymous (logged-out) SSE
- Replacing Realtime or RongCloud
- RAG, CRM tools, real inventory/quoting
- bfui module changes
- Mandatory production LLM in phase 1 (config switch only)

## Further Notes

- Glossary: `docs/contexts/ai-little-stone/CONTEXT.md`
- Protocol deep-dive: `docs/sse-streaming-design.md` (update to Accepted / visit-conversation decisions)
- Go pointer: `my_go_study/docs/sse-streaming.md`
- ADR: `docs/adr/0005-sse-visit-conversation-not-realtime-im.md`
- Next step per flow: `/to-tickets` under `.scratch/ai-little-stone/issues/`
