---
label: ready-for-agent
feature: vercel-ui
source: DESIGN.md (Vercel)
adrs: 0002, 0003, 0004
---

# Spec: Vercel Design Source of Truth → Production Surface

## Problem Statement

App 的生产界面仍是 iOS 风全局主题加各 feature 私有色板，与仓库根目录 `DESIGN.md`（Vercel）不一致。用户与 Agent 无法按同一套视觉语言生成或改 UI；深色模式在壳层存在，但多数页面只有浅色硬编码。需要把除 bfui 外的全部生产界面改到 Design Source of Truth，并分步做完逐屏过稿。

## Solution

以根目录 `DESIGN.md` 为 Design Source of Truth：在 `module_common_ui` 建立浅/深一体的 Vercel Token API，改造共享脚手架，再按里程碑对全部 Production Surface 做 Screen Visual Pass。取消 Category Skin；Mesh Accent 仅用于少数 Hero/空态。手机使用 Mobile Type Scale（角色严格、物理尺寸换算）。单页以 Visual Pass Checklist 验收。bfui 不在范围内。

## User Stories

1. As an app user, I want the whole production app to share one Vercel look (light), so that screens feel like one product instead of mixed iOS skins.
2. As an app user, I want a coherent dark mode using the same Vercel language, so that toggling theme does not expose leftover light-only pages.
3. As an app user, I want primary buttons, inputs, and nav to match DESIGN.md component rules, so that controls feel consistent everywhere.
4. As an app user, I want list and form pages to stay calm (canvas + hairline), so that everyday tasks are not buried under marketing gradients.
5. As an app user, I want occasional Mesh Accent on heroes/empty states, so that brand energy appears without turning every tab into a landing page.
6. As an app user, I want chat to use Vercel surfaces instead of an iMessage skin, so that messaging matches the rest of the app.
7. As an app user, I want classroom and pay screens to drop green/custom brand skins, so that only semantic colors (link/error/warning) stand out.
8. As an app user, I want music screens to follow system light/dark tokens, so that forced local dark themes no longer fight the app setting.
9. As an app user, I want analytics charts to keep clear emphasis zones, so that snapshot metrics stay readable under Vercel tokens.
10. As an app user, I want immersive video playback to stay full-bleed and system-bar-hidden, so that watching is not broken by the visual refresh.
11. As an app user, I want immersive playback controls and labels to use Vercel typography/colors, so that chrome matches the design system.
12. As an app user, I want Geist / Geist Mono throughout production UI, so that type matches the Design Source of Truth.
13. As an app user, I want type on phones to stay readable, so that display roles scale down via Mobile Type Scale instead of raw web 48px.
14. As a developer, I want a single Vercel Token API in the shared UI module, so that I never invent another feature-local color class.
15. As a developer, I want feature `*Theme` classes retired, so that Design Source of Truth has one code path.
16. As a developer, I want shared scaffolds (page, nav, tab bar, buttons, inputs, list cards) token-driven, so that screen passes start from correct primitives.
17. As a developer, I want chart colors to consume the Token API, so that analytics does not keep a private accent brand.
18. As a developer, I want a Visual Pass Checklist per screen, so that “done” is objective without screenshot golden files.
19. As a developer, I want phased milestones that still end at full completion, so that work can ship incrementally without declaring victory early.
20. As a developer, I want main tabs visually passed before secondary features, so that daily navigation reflects the new language first.
21. As a developer, I want auth, video, classroom, pay, music, live, and friend screens included before close-out, so that no production module is left half-migrated.
22. As a developer, I want a final hard-coded color sweep, so that stray `#007AFF` / iOS greys do not remain.
23. As a developer, I want bfui left unchanged, so that demo templates do not pollute the production design system.
24. As an Agent, I want CONTEXT / ADR vocabulary (Production Surface, Token API, Screen Visual Pass, etc.), so that tickets and reviews use the same words.
25. As an Agent, I want DESIGN.md plus this spec as the visual contract, so that implementing a screen does not require re-grilling.
26. As a QA-minded developer, I want themeMode toggle to switch scaffold/button/input tokens in one place, so that dark mode regressions are caught at the Token API seam.
27. As a QA-minded developer, I want scaffold tests proving key widgets read tokens not hard-coded iOS blue, so that Category Skin cannot quietly return in shared chrome.
28. As a settings user, I want the existing dark-mode control to drive the new dark token set, so that I do not need a second theme switch.
29. As a future maintainer, I want rejected approaches recorded (inspired-only, light-only phase, keep feature themes), so that we do not reopen settled trade-offs.

## Implementation Decisions

### Scope and phasing

- **In scope**: Production Surface only (shell, `module_common_ui`, all business features except bfui).
- **Out of module**: `module_bfui` untouched.
- **Phased Completion order** (must finish all):
  1. Theme Layer — light/dark Vercel Token API + shell `ThemeData`
  2. Shared scaffolds — page / nav / tab bar / buttons / inputs / list cards
  3. Main tabs — home → chat → community → mine
  4. Remaining business — auth, video, classroom, pay, music, live, friend, and other production routes
  5. Close-out — chart colors, hard-coded color sweep, dark-mode acceptance
- Depth: every in-scope screen gets a Screen Visual Pass (layout/hierarchy/component states), not token swap alone.

### Design strictness

- Strict Design Source of Truth: colors, component states, decorative system from root `DESIGN.md`.
- Mobile Type Scale: keep roles and relative weight/tracking; use phone conversion table below (not raw web px).
- Mesh Accent: heroes / empty states only.
- No Category Skin: chat/classroom/music/analytics visual morphologies converge to DESIGN.md components; semantic roles (link/error/warning/success) remain.

### Theme architecture

- Single Vercel Token API in shared UI package; mounted on app `ThemeData` for light and dark.
- Retire feature-local `*Theme` static palettes; screens read Token API / `Theme.of` only.
- Bundle Geist + Geist Mono (SIL OFL); ship license files with the font assets.
- Remove music (and similar) local `Theme(data: …)` overrides that fight global themeMode.
- Immersive Playback Shell: keep immersive system UI behavior; restyle controls/labels via tokens.

### Mobile Type Scale (phone, logical px)

| Role | DESIGN.md web | Phone |
|------|---------------|-------|
| display-xl | 48 | 32 |
| display-lg | 32 | 28 |
| display-md | 24 | 22 |
| display-sm | 20 | 18 |
| body-lg | 18 | 17 |
| body-md / body-md-strong | 16 | 16 |
| body-sm / body-sm-strong | 14 | 14 |
| caption / caption-mono | 12 | 12 |
| code | 13 | 13 |
| button-lg | 16 | 16 |
| button-md | 14 | 14 |

Weights, letter-spacing ratios, and font families follow `DESIGN.md`. Spacing/radius tokens use DESIGN.md values unless a scaffold must shrink for touch density (document exceptions in ticket notes).

### Dark tokens

- Deliver a full dark token set aligned with DESIGN.md / preview-dark semantics (ink/canvas inversion, hairline, link, status colors).
- Settings theme toggle continues to drive `ThemeMode`; both modes must pass Visual Pass Checklist on touched screens.

### charts

- Chart color DTO / theme consumes Token API; Analytics Chart Emphasis Zone remains a layout concept under Vercel colors.

### Testing seams (agreed)

- **Primary seam**: Vercel Token API (light/dark semantic colors + Mobile Type Scale roles).
- **Secondary seam**: shared scaffolds reading tokens (no hard-coded legacy accent).
- **No** screenshot golden-file seam for Screen Visual Pass.

### Issue tracking

- Spec and tickets live under `.scratch/vercel-ui/` (local markdown tracker).

## Testing Decisions

- Good tests assert **external behavior**: given ThemeData, token getters / ColorScheme / TextTheme expose expected semantic values; scaffolds resolve colors from theme, not from legacy constants.
- Do **not** test private field layout of ThemeExtension implementation details beyond the public Token API.
- Modules under automated test first: Token API unit/widget tests; thin scaffold widget tests for primary button, page background, tab bar selected color.
- Prior art: existing package tests under `commons/` and feature `test/` folders; prefer `flutter_test` + widget pump with injected `Theme`.
- Screen Visual Pass: checklist only (manual/agent), not golden screenshots.
- Checklist items per screen:
  1. No feature-private theme imports
  2. No disallowed hard-coded palette (legacy iOS blue/greys outside semantic exceptions)
  3. Component states match DESIGN.md roles
  4. Light and dark each reviewed once
  5. Mesh Accent only in allowed placements
  6. Immersive pages still immersive where required

## Out of Scope

- Entire `module_bfui` demo kit and its fonts/themes
- Redesigning backend APIs, auth flows, or business logic
- Screenshot / visual-regression golden files
- Replacing fl_chart / `wys_chart` chart engines (colors only)
- Building a separate marketing website
- Changing AGENTS.md modular architecture boundaries except theme consumption patterns
- Filing GitHub Issues for this work (local `.scratch` only unless later migrated)

## Further Notes

- Glossary: `docs/contexts/app-visual-design/CONTEXT.md`; map: `CONTEXT-MAP.md`.
- ADRs: `0002` (full production UI), `0003` (Token API), `0004` (mobile type scale + checklist).
- Next skill step: `/to-tickets` — split into tracer-bullet tickets with blocking edges, blockers-first.
- First implement ticket after tickets exist should land Theme Layer + enough scaffold that one main tab can demonstrate the language; full main-tab passes follow in subsequent tickets.
