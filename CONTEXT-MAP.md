# Context Map

## Contexts

- [Data Analytics](./CONTEXT.md) — 首页「数据分析」列表与详情的可视化展示语境
- [App Visual Design](./docs/contexts/app-visual-design/CONTEXT.md) — 全 App（除 bfui）的视觉语言与主题边界
- [AI 小石头](./docs/contexts/ai-little-stone/CONTEXT.md) — 首页「AI小石头」业务向导助手（气泡多轮 + SSE）
- [Auth Session](./docs/contexts/auth-session/CONTEXT.md) — 壳工程登录/注册与本地认证会话边界

## Relationships

- **App Visual Design → Data Analytics**: Analytics 的色板与强调区必须落在 App Visual Design 的 token / 主题层内，不再各自维护「iOS 蓝」式独立品牌色
- **App Visual Design → AI 小石头**: 助手页使用生产 Token / 脚手架，不走 bfui 演示主题
- **AI 小石头 ↛ Chat（融云）**: 助手停留会话与 IM 聊天会话分离；不复用 RongCloud 消息模型
- **Auth Session → 各需登录 feature**: 业务只读 Session Owner 暴露的登录态，经 Login Gate 邀请登录；不自建 token 存储
- **Auth Session ↛ wys_account**: 当前产品不把 `wys_account` 当 Session Owner
- **bfui**: 不在 App Visual Design 范围内；保持独立演示主题
