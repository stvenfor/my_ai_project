# ADR 0004: 手机字号换算与过稿验收

## Status

Accepted

## Context

已决定严格遵循根目录 `DESIGN.md`，但 Web Display 字号不能原样上手机；同时需要可执行的「单页完成」定义，并处理沉浸视频页与主题改造的关系。

## Decision

1. **Mobile Type Scale**：保留 DESIGN.md 的字体角色与比例；手机物理尺寸用换算表（写入后续 spec），不照搬 48px Display XL。
2. **验收**：以 Visual Pass Checklist 为准；不做截图黄金文件 / 视觉回归基线。
3. **沉浸页**：保留 `VideoPlaybackImmersiveScope` 行为；控件与文字仍 Vercel 化，不整类延期、不取消沉浸。
4. **下一流程**：grilling 结束后走 `/to-spec` → `/to-tickets` → 分票实现；第一张实现票交付主 Tab 样板，不开独立 prototype 目录。

## Consequences

- Spec 必须包含手机字号换算表与过稿清单，否则「严格 DESIGN.md」会对手机不可执行。
- 实现顺序仍以主题层与脚手架为先，避免逐屏过稿时重复改 token。
