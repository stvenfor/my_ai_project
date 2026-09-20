# 12 — Music Screen Visual Pass

**What to build:** Music production surfaces complete Screen Visual Pass and follow the global light/dark Token API; local forced-dark `Theme` overrides are removed.

**Blocked by:** 02 — Shared scaffolds on Token API

**Status:** done

- [x] Removed local `Theme(data: music*DarkTheme)` overrides; pages follow app themeMode
- [x] `musicListDarkTheme` / `musicDarkTheme` alias to `AppTheme.dark` for leftover imports
- [ ] Full Visual Pass Checklist (light + dark) on list + now playing chrome
