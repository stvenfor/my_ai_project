## Context

见 proposal.md Why。现状：`NetworkCodes` 无 403；`ResponseHandlerInterceptor.onResponse` 仅对 status `401` 提前分支并调 `onTokenExpired`；`onError` 同样只特判 401/429。`module_core.classifyAuthHttp` 已约定 HTTP 403 → `forbidden`（不登出）。本变更在本仓 `commons/wys_network` 对齐该语义，并补齐拦截器显式分支。

## Goals / Non-Goals

**Goals:**

- `NetworkCodes.forbidden = 403` + `WysNetworkError.isForbidden`。
- 新增 `onForbidden`；拦截器在 `onResponse` / `onError` 显式处理 403。
- 403 **永不**触发 `onTokenExpired`。

**Non-Goals:**

- 不改 `module_http` / auth Session Owner / Go BFF。
- 不强制主工程立刻注册 `onForbidden`（未注册时仅不登出；`autoToastOnFailure` 时可 toast 无权限文案）。
- 不批量替换全仓字面量 `403`。

## Decisions

1. **常量名 `forbidden`**
   - 与 `AuthHttpDecision.forbidden` 一致；值 `403`。

2. **新增 `onForbidden`，不复用 `onBusinessFailure` 作为唯一出口**
   - Rationale：与 `onNetworkBusy` / `onTokenExpired` 对称，主工程可单独接线权限 UI；仍可在分支内顺带走 toast。
   - Alternative：只调 `onBusinessFailure` —— 可区分性差，主工程难专接 403。

3. **拦截器处理顺序（`onResponse`）**
   - 在现有 `expireToken`（401）分支旁增加 **HTTP status == forbidden** 提前分支：读 body `message`（缺省「无权限」）→ `WysNetworkError.business(code: forbidden)` → `onForbidden?.call` → `handler.next`（或 `throwOnBusinessError` 时 reject，与其它业务码一致）。
   - Map body 内 `code == forbidden`：在 `expireToken` 业务码分支之后、通用 `onBusinessFailure` 之前增加对称分支。
   - **禁止**把 403 并入 401 分支。

4. **`onError`**
   - `status == forbidden` → `onForbidden?.call(tf)`；若 `autoToastOnFailure` 且 message 可用则 toast（缺省「无权限」）。
   - 不得落入 `expireToken` 条件。

5. **`HttpsClient._parseResponse`**
   - 保持 401 专用逻辑；403 走通用 ≥400 / Map 解析，必要时用 `NetworkCodes.forbidden` 填 `ApiResponse.code`。

## Risks / Trade-offs

- **[Risk] Dio 将 403 放进 `onError` 而非 `onResponse`（取决于 validateStatus）** → Mitigation：`onResponse` 与 `onError` 双侧都处理。
- **[Risk] 与 `AuthBizCode.forbidden`（10003）混淆** → Mitigation：仅 HTTP/status catalog 用 403；文档与常量注释标明。
- **[Trade-off] 未注册 `onForbidden` 时 UI 无全局弹层** → 与现有多数业务码一致；业务页可继续本地判断 `isForbidden` / statusCode。

## Migration Plan

1. 合入常量、`isForbidden`、`onForbidden`、拦截器双侧分支。
2. 可选：主工程注册 `onForbidden`（Toast/Dialog）。
3. 回滚：删除上述符号与分支即可。

## Open Questions

- 无。
