# Auth follow-ups (post auth-session)

## wys_account
- Deprecated (ADR 0009); removed from root pubspec; package retained.

## Refresh success
- Covered by seam test + ADR 0011.
- Manual: cold start with Go up should rotate tokens without logout (optional log check).

## Phone OTP (dev)
- Go test number: `13400000000` / OTP `123456` (non-release).
- Seam tests cover verify → Auth Session.
- Manual on shell: switch to phone login → send code → `123456` → enter main / see user.

**Status:** code done; OTP UI smoke optional
