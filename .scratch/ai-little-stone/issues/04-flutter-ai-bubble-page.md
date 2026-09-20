# 04 — Flutter：AI 小石头气泡页（接真 SSE）

**What to build:** 用户进入独立助手页后，可用气泡多轮对话：快捷问/输入发送、助手纯文本流式回复、停止生成、单轮在途、失败保留半截文字。首句从 `meta` 收下 `conversationId` 供后续轮次使用；离开页清空本地会话（与停留会话语义一致）。本票可先在无 Redis 多轮的后端上跑通单轮，但多轮语境验收依赖票 03。

**Blocked by:** 01 — Go：SSE 单轮 Mock 流；02 — Flutter：SseClient + 解析器

**Status:** ready-for-agent

- [x] 新建 `module_ai` 并注册路由；助手页为客服式气泡 UI（纯文本）
- [x] 欢迎区含客户端快捷问；点击即发送用户消息
- [x] 流式中显示停止；停止后保留已生成文字；流式中禁用发送
- [x] 失败时保留半截 + 气泡内错误提示，可继续发下一句
- [x] 消费 `meta.conversationId`；页面销毁时丢弃本地 id 与气泡
- [x] 门面/Controller 缝有测试：流式追加、停止、单轮在途、错误态
