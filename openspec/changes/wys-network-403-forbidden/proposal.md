## Why

`wys_network` 的 `NetworkCodes` 与 `ResponseHandlerInterceptor` 已处理 401（登出）与 429（拥堵），但接口会返回 **HTTP 403** 表示无权限。缺少命名常量时只能写魔法数字；拦截器若不显式处理 403，易与 401 混淆，或把无权限错误当成通用网络故障 toast。

## What Changes

- 在 `NetworkCodes` 增加 `forbidden = 403`。
- 在 `WysNetworkError` 增加 `isForbidden`。
- 在 `network_events.dart` 增加 `onForbidden` 回调（与 `onNetworkBusy` 同级）。
- **`ResponseHandlerInterceptor` 显式处理 403**：
  - `onResponse`：HTTP status 403（及业务 `code == 403`）→ 构造错误、调用 `onForbidden`，**不**调用 `onTokenExpired`。
  - `onError`：HTTP status 403 → 同样走 `onForbidden`，不走登出。
- `HttpsClient` 解析路径保持 403 与 401 分支分离。
- 与 `module_core.classifyAuthHttp` / SessionGuard「403 = forbidden、不登出」语义对齐；不改 Session Owner。

## Capabilities

### New Capabilities

- `wys-network/http-status-codes`: `wys_network` 共享状态码目录，以及响应拦截器对 HTTP/业务 403 与 401 的处理边界。

### Modified Capabilities

- （无）本仓库 `openspec/specs/` 尚无既有能力。

## Impact

- `commons/wys_network/lib/src/network_codes.dart`
- `commons/wys_network/lib/src/wys_network_error.dart`
- `commons/wys_network/lib/src/network_events.dart`
- `commons/wys_network/lib/src/interceptor/response_handler_interceptor.dart`
- `commons/wys_network/lib/src/https_client.dart`（必要时与 401 分支分离）
- 主工程若注册了 `onTokenExpired`，可按需注册 `onForbidden`；未注册时行为与现有业务失败一致（可选 toast）。
- **非目标**：不改 Go BFF；不把 `AuthBizCode.forbidden`（10003）与 HTTP 403 混用；不批量替换全仓字面量 `403`。
