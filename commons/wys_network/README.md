# wys_network

对齐 **`tf-fangroup-flutter`**（`HttpUtil` / `DioRequest`）与 **iOS** `TFNetworkManager` 的 Dio 封装。

## 初始化

```dart
import 'package:wys_network/wys_network.dart';

void main() {
  // debug → https://appdev.tfent.cn（与 iOS 测试环境一致）
  AppEnvironment.initialize(AppEnv.debug);

  // 或显式三档（对齐 TFTestBall.m）：
  // AppEnvironment.initialize(AppEnv.debug, netEnvironment: WysNetEnvironment.dev);
  // AppEnvironment.initialize(AppEnv.release, netEnvironment: WysNetEnvironment.product);
}
```

| iOS | Flutter |
|-----|---------|
| `TFTestBall.m` `baseUrl` | `WysApiHosts` |
| `kEnvironmentKey` = `enviromentKey` | `WysNetEnvironmentStore.prefsKey` |
| 存 100/200/300/0 | `valueDev` / `valueTest` / `valueProduct` / `valueCustom` |
| `+[TFTestBall startTest]` 绿球 | `WysTestBall`（`kDebugMode`） |
| `WysBaseUrlAlertController` | `showWysBaseUrlSheet` |
| 确定 → 登出提示 | `onEnvironmentChanged` → `WysAccount.logout` |
| `TF_NET_PRODUCT` / `TF_NET_TEST` 宏 | `--dart-define=TF_NET_PRODUCT=true` |
| `FlutterUtil packTokenForFlutter` url | `TFUrl getApiHost` = `TFTestBall.baseUrl` |

| 环境 | 域名 |
|------|------|
| 开发 DEV | `http://tf.wohkn.cn` |
| 测试 TEST | `https://appdev.tfent.cn` |
| 正式 PRODUCT | `https://app.tfent.cn` |

```bash
# 对齐 iOS 编译宏
flutter run --dart-define=TF_NET_TEST=true
flutter run --dart-define=TF_NET_PRODUCT=true
```

## 默认请求头（与旧工程一致）

| Header | 来源 |
|--------|------|
| `Client-Type` | Android / iOS / Flutter |
| `Client-Version` / `Client-BuildNumber` | `WysNetworkConfig` |
| `sysCode` | `tf` |
| `isStar` / `subjectId` | `WysNetworkConfig`（iOS 明星账号） |
| `Authorization` | `Bearer` + token（`cos.tfent.cn` 除外） |

## 混编（Boost / 原生壳）

```dart
nativeAuthProvider = () async {
  final map = await channel.invokeMethod('getUserToken');
  return NativeSession(
    url: map['url'],
    token: map['token'],
  );
};
// token/baseUrl 变化后
HttpsClient.applySession(session);
```

## 业务码（iOS `TFErrorCode.m`）

| code | 含义 | 回调 |
|------|------|------|
| 200 | 成功 | — |
| 100 + data=1 | 未成年认证 | `onInvalidAuth` |
| 301 | 无会员 | `onInvalidMember` |
| 401 | token 失效 | `onTokenExpired` |
| 429 | 拥堵 | `onNetworkBusy` |
| 500 | 账号注销等 | `onInvalidAccount` |
| -1 | 透传原始 JSON | 不 reject |

主工程注册 UI：

```dart
onTokenExpired = (_) async => WysAccount.logout();
globalToastHandler = (msg) => Get.snackbar('提示', msg);
```

## API 用法

```dart
// 类型化
final res = await HttpsClient.instance.getApi<Map<String, dynamic>>('/member-v2/...');
if (res.isSuccess) { ... }

// 兼容旧 Flutter HttpUtil.request
final data = await HttpsClient.instance.request('/path', 'POST', data: body);
```

## 参考文件

- Flutter：`tf-fangroup-flutter/lib/util/HttpUtil.dart`、`lib/api/DioRequest.dart`
- iOS：`TFFanclub/Class/Manager/Http/TFNetworkManager.m`