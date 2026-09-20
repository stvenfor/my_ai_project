# ADR 0002: 以根目录 DESIGN.md（Vercel）全量改造生产 UI

## Status

Accepted

## Context

根目录已放入 Vercel `DESIGN.md`。现有 UI 是 iOS 风全局 `AppTheme` + 各 feature 浅色 `*Theme`，与真源不一致。需要明确范围、深度、移动端严格度与深色策略。

## Decision

1. **范围**：全部 Production Surface（壳、`module_common_ui`、除 bfui 外全部业务模块）。**bfui 不改**。
2. **深度**：必须做完逐屏视觉过稿（不只换 token）；可分步实施，但终点是全部改完。
3. **严格度**：严格遵循 `DESIGN.md`（色、字、组件态、装饰系统），不是「inspired 收紧版」。
4. **深色**：浅色与深色两套 token / 主题一并交付（对齐 DESIGN.md 与 preview-dark 语义），保留系统/设置切换。

## Consequences

- 现有 Chat iMessage、Classroom 绿强调、Music 局部强制深色、Analytics 独立强调色等，最终都要收敛到 Design Source of Truth（语义色可保留角色，品牌形态不保留）。
- 工作量跨多会话：须先主题层与共享脚手架，再按模块逐屏过稿；应用 `/to-spec` → `/to-tickets` 拆票。
- 严格 Web 字号/留白直接上手机可能过疏或过大——具体缩放规则在 grilling 后续轮次拍板后写入实现 spec，不削弱「以色板与组件规则为准」的决策。
