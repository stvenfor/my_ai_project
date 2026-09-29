## 1. Constants and events

- [x] 1.1 Add `NetworkCodes.forbidden = 403` in `commons/wys_network/lib/src/network_codes.dart` (near `expireToken`)
- [x] 1.2 Add `WysNetworkError.isForbidden` in `wys_network_error.dart` (mirror `isTokenExpired` / `isBusy`)
- [x] 1.3 Add `NetworkEventHandler? onForbidden` in `network_events.dart` and export if needed

## 2. Response interceptor 403 handling

- [x] 2.1 In `ResponseHandlerInterceptor.onResponse`, add HTTP status `forbidden` branch beside 401: build error, call `onForbidden`, never `onTokenExpired`
- [x] 2.2 In `onResponse` Map body path, add business `code == forbidden` branch before generic `onBusinessFailure`
- [x] 2.3 In `onError`, handle `status == forbidden` via `onForbidden` (+ optional toast); keep distinct from 401/429 branches
- [x] 2.4 Ensure `HttpsClient._parseResponse` does not route 403 through the 401 special case

## 3. Verify

- [x] 3.1 Analyzer on `commons/wys_network`
- [x] 3.2 Spot-check: synthetic 403 → `isForbidden == true`, `isTokenExpired == false`, `onTokenExpired` not invoked
