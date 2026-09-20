# 06 — Go：Provider 开关 + 限流/配置打磨

**What to build:** 运维可通过配置在 `mock` 与 `openai_compatible` 间切换而不改路由；默认 mock。按用户限流与 SSE 相关配置项就绪，即使未配置真 key 也能保持 mock 可用，并具备切换到兼容接口的接线形状。

**Blocked by:** 03 — Go：停留会话

**Status:** ready-for-agent

- [x] 配置项可选择 `mock | openai_compatible`，默认 mock
- [x] OpenAI 兼容实现可装配（密钥仅环境/配置，Flutter 不持有）；无 key 时 mock 仍为默认可用路径
- [x] 按 user 限流，超限返回明确错误（流前或约定错误码）
- [x] prompt/maxTokens 等上限可配置并生效
- [x] 文档/配置示例说明如何切换 Provider
