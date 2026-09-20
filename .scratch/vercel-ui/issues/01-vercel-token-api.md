# 01 — Vercel Token API + Geist + light/dark ThemeData (expand)

**What to build:** The app shell can present light and dark themes whose semantic colors and type roles match the Design Source of Truth (`DESIGN.md`), including bundled Geist fonts and Mobile Type Scale. Legacy `AppTheme` static colors still compile (aliases / coexistence) so the rest of the app does not break.

**Blocked by:** None — can start immediately.

**Status:** done

- [x] Vercel Token API exists in shared UI and is mounted on light and dark `ThemeData`
- [x] Geist + Geist Mono are bundled with OFL license files
- [x] Mobile Type Scale roles match the spec table
- [x] Shell `theme` / `darkTheme` use the new ThemeData
- [x] Legacy `AppTheme` color getters still resolve (expand; no mass call-site rewrite yet)
- [x] Primary-seam tests cover light/dark semantic colors and type roles
