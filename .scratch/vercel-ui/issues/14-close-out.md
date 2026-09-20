# 14 — Close-out: retire themes, contract, sweep

**What to build:** Production Surface is fully closed out: feature `*Theme` classes and legacy `AppTheme` iOS constants are contracted away, production-referenced `wys_common` surfaces match tokens, chart colors use Token API, and a hard-coded legacy-color sweep leaves no stray iOS blue/greys. bfui remains untouched.

**Blocked by:** 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13

**Status:** ready-for-agent

- [ ] No production feature `*Theme` palette remains as source of truth
- [ ] Legacy iOS `AppTheme` constants removed or reduced to thin Token API facades only if still required
- [ ] Production `wys_common` touchpoints restyled
- [ ] Chart colors consume Token API
- [ ] Hard-coded `#007AFF` / iOS grey sweep clean on Production Surface (bfui excluded)
- [ ] Light + dark acceptance on main tabs and settings toggle
