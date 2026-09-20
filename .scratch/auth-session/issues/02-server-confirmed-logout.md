# 02 — Server-Confirmed Logout（Gone + MockLocal）

**What to build:** 真实后端下，主动登出须服务端确认成功才清除本地 Auth Session 并允许回到登录门；若服务端表示 token/会话已不存在，视为登出已完成并清本地；网络失败或拒绝退出则保持登录并提示。Mock 模式下登出仍立刻清本地。

**Blocked by:** None — can start immediately

**Status:** done

- [x] 真实模式：logout API 成功 → 本地会话清除
- [x] 真实模式：会话已不存在 / 等价无效凭证 → 本地会话清除（Gone）
- [x] 真实模式：网络错误或非 Gone 的失败 → 本地会话保留 + 用户可见错误
- [x] Mock 模式：登出立刻清本地（MockLocal）
- [x] 主缝自动化覆盖上述分支
