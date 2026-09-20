# 03 — AuthNavigation：Invite Login + Force Reset Login

**What to build:** 壳工程「请登录」统一走 Invite Login（`AuthNavigation.openLogin`，可带回跳）。会话失效或登出成功后走 Force Reset Login（清栈回到登录门），二者同属 `AuthNavigation`、意图分离。收敛壳内直接点名登录路由的邀请路径。

**Blocked by:** 02 — Server-Confirmed Logout（Gone + MockLocal）

**Status:** done

- [x] Invite Login 为壳内需登录功能的统一打开方式
- [x] Force Reset Login 用于失效守卫与登出成功后的清栈回登录
- [x] 邀请路径不再散落直接 `toNamed(login)`（linking / 我的 / 主 Tab 等已收敛）
- [x] 导航缝可验证两种意图不被混用
