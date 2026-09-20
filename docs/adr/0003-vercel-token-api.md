# ADR 0003: 单一 Vercel Token API，退役 feature 本地主题

## Status

Accepted

## Context

生产 UI 现有全局 iOS 风 `AppTheme` 与十余个 feature `*Theme` 静态色，和根目录 `DESIGN.md` 冲突。需要决定 token 住哪、旧主题怎么退。

## Decision

1. 在 `module_common_ui` 建立**唯一**浅色/深色 Vercel Token API（ThemeExtension 或等价），由壳 `ThemeData` 挂载。
2. 打包 **Geist + Geist Mono**（SIL OFL，可随 App 分发；附带许可证文件）。
3. 各 feature `*Theme` **最终退役**；页面与共享脚手架只读 Token API。
4. 取消 Category Skin；`wys_common` 仅改生产仍引用的表面。
5. Mesh Accent 仅用于少数 Hero/空态，不铺满主 Tab。

## Consequences

- 逐屏过稿前必须先落地 Token API 与脚手架，否则会重复改色。
- Music 等局部 `Theme(data: …)` 覆盖需拆除，改走全局浅/深。
- Analytics「图表强调区」继续存在为布局概念，但色板改走 Token API，不再维护独立 iOS 蓝强调。
