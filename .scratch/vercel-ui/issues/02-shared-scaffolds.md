# 02 — Shared scaffolds on Token API

**What to build:** Shared page chrome (page scaffold, nav bar, tab bar, primary/secondary buttons, inputs, list cards) reads the Vercel Token API so everyday navigation already looks Vercel before feature screen passes.

**Blocked by:** 01 — Vercel Token API + Geist + light/dark ThemeData (expand)

**Status:** done

- [x] Scaffold / nav / tab / buttons / inputs / list cards use Token API (no hard-coded legacy iOS accent in those widgets)
- [x] Light and dark each look correct for shared chrome
- [x] Thin scaffold tests assert token-driven colors, not `#007AFF` literals
