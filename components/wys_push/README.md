# wys_push 鸿蒙极光推送接入说明

`wys_push` 是项目内的极光推送组件，当前只实现 HarmonyOS。组件负责极光 SDK 初始化、环境 AppKey、消息解析、事件缓存、Want 深链接收、点击去重、路由调度、alias、角标和 RegistrationID；登录、隐私协议、具体路由实现及业务处理仍由应用层负责。

## 1. 依赖关系

组件通过 Flutter 插件接入极光：

```yaml
dependencies:
  wys_network:
    path: ../../commons/wys_network

  jpush_flutter:
    git:
      url: https://github.com/jpush/jpush-flutter-plugin.git
      ref: dev-3.x
```

当前依赖链：

```text
wys_push
  └── jpush_flutter 3.4.9
        └── @jg/push 1.4.0
```

`@jg/push` 已由 `jpush_flutter` 的鸿蒙模块引入，主工程的 `ohos/entry/oh-package.json5` 不需要重复声明。

## 2. 项目配置

### 2.1 HarmonyOS SDK

```bash
export HOS_SDK_HOME="/Applications/DevEco-Studio.app/Contents/sdk"
export HDC_HOME="$HOS_SDK_HOME/default/openharmony/toolchains"
export PATH="$HDC_HOME:$PATH"
```

Flutter SDK 配置：

```bash
flutter config --enable-ohos
flutter config --ohos-sdk "$HOS_SDK_HOME"
```

### 2.2 字节码 HAR

工程级 `ohos/build-profile.json5` 的每个 product 都要打开：

```json5
"buildOption": {
  "strictMode": {
    "useNormalizedOHMUrl": true
  }
}
```

### 2.3 包名和 client_id

`ohos/AppScope/app.json5`：

```json5
"bundleName": "com.tf.hm"
```

`ohos/entry/src/main/module.json5`：

```json5
"metadata": [
  {
    "name": "client_id",
    "value": "6917611599127957264"
  }
]
```

`client_id` 必须是 AppGallery Connect 中具体应用的 client_id，不是项目 client_id。

### 2.4 签名与控制台

需要在 AppGallery Connect 和极光控制台确认：

- 应用包名为 `com.tf.hm`。
- HarmonyOS Push Kit 已开通。
- Debug、Release 使用的 SHA256 证书/公钥指纹已添加。
- 极光后台已配置 HarmonyOS 平台参数。
- 极光应用的包名、AppKey 与本地一致。

## 3. AppKey 与环境

AppKey 由 `AppEnvironment.instance.netEnvironment` 动态决定：

| 网络环境 | 极光环境 | AppKey |
| --- | --- | --- |
| `dev` | 测试 | `11a0ffe89abbde2be74043f4` |
| `test` | 测试 | `11a0ffe89abbde2be74043f4` |
| `custom` | 测试 | `11a0ffe89abbde2be74043f4` |
| `product` | 正式 | `d393c17a7cb3af79e6d56371` |

业务层不应再单独保存 `_isProduction`，也不要手工切换推送环境。

## 4. 初始化时序

### 4.1 为什么进入首页才初始化

`jpush_flutter dev-3.x` 的 HarmonyOS 实现有两个需要注意的行为：

1. `setAuth()` 在 HarmonyOS 没有实现，调用 `setAuth(false)` 不能阻止 SDK 初始化。
2. `setup()` 内部会调用 `requestEnableNotification()`，立即申请系统通知权限。

为了避免通知权限弹窗覆盖服务协议与隐私政策弹窗，并对齐 Android 进入首页后申请 `POST_NOTIFICATIONS` 的时机，HarmonyOS 在进入首页后才执行 `setup()`。

```text
启动应用
  → 显示服务协议与隐私政策
  → 用户同意
  → 进入登录页
  → 登录成功进入首页
  → PushManager.init()
  → jpush.setup()
  → 系统通知权限弹窗
  → 获取 serialNo
  → setAlias(serialNo)
```

未同意隐私协议、登录页和 Splash 均不得调用 `init()` 或 `reInit()`。

### 4.2 应用入口注入

在应用启动时只注入实现和注册通用事件监听，不执行极光 setup：

```dart
PushManager.instance = JPushManager();
WysPushCoordinator.instance.init(
  onRoute: WysRouter.routeURL,
  onNotificationArrived: handleBusinessNotification,
  onNotificationOpened: handleBusinessNotification,
);
```

### 4.3 首页初始化

```dart
@override
void onInit() {
  super.onInit();
  PushManager.instance.init();
  PushManager.instance.setBadgeNum(0);
}
```

`JPushManager` 会记录当前 AppKey。相同 AppKey 重复调用 `init()` 时会跳过 setup，事件回调也只注册一次。

应用进入主 Tabs 且路由可用后统一释放冷启动缓存：

```dart
WysPushCoordinator.instance.markAppReady();
```

协调器会合并同一次通知点击产生的极光回调和 Want URI，避免重复跳转。主 Tab 切换、泡泡刷新等业务行为通过回调留在应用层，`wys_push` 不依赖 GetX 或具体功能模块。

## 5. 通知点击 Want

`TfDeepLinkPlugin` 已随 `wys_push` 的 OHOS 原生插件发布并由 Flutter 自动注册，宿主不再保存或手动注册插件实现。通知冷启动和热启动点击只需在 `ohos/entry/src/main/ets/entryability/EntryAbility.ets` 转交 `Want`：

```ts
import JpushHarmonySdkPlugin from 'jpush_flutter';
import TfDeepLinkPlugin from 'wys_push';

export default class EntryAbility extends FlutterAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    TfDeepLinkPlugin.offerWant(want)
    await super.onCreate(want, launchParam)
    JpushHarmonySdkPlugin.setClickWant(want, this.context)
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    TfDeepLinkPlugin.offerWant(want)
    super.onNewWant(want, launchParam)
    JpushHarmonySdkPlugin.setClickWant(want, this.context)
  }
}
```

两处缺一不可：`onCreate` 处理冷启动，`onNewWant` 处理应用存活时再次点击通知。`TfDeepLinkPlugin` 负责从 Want 提取并缓存 URI；`setClickWant` 负责把通知点击交给极光 SDK，后续点击数据通过极光回调到 Dart，二者由协调器去重。

## 6. alias 与登录状态

用户进入首页、极光初始化完成并获得用户 `serialNo` 后绑定：

```dart
await PushManager.instance.setAlias(serialNo);
```

退出登录、Token 失效或切换网络环境前删除旧 alias：

```dart
await PushManager.instance.deleteAlias();
await WysAccount.logout();
```

环境切换后不要在登录页立即 `reInit()`。用户重新登录进入首页时，组件会读取新的网络环境，用对应 AppKey 执行 setup，再绑定新环境 alias。

## 7. 推送事件

组件统一输出以下事件：

| `PushEventType` | 说明 |
| --- | --- |
| `notificationArrived` | 通知到达 |
| `notificationOpened` | 用户点击通知 |
| `customMessage` | 自定义消息 |

`PushEventDispatcher` 提供：

- SDK 事件订阅。
- 应用未就绪时缓存事件。
- 应用就绪后按原顺序派发。
- 到达、点击和自定义消息的独立回调。

首页和路由准备完成后通知组件：

```dart
WysPushCoordinator.instance.markAppReady();
```

具体 deeplink 路由、泡泡刷新等业务逻辑通过 `WysPushCoordinator.init()` 的回调注入，不能让 `wys_push` 依赖业务模块。

## 8. 自定义消息（可选）

普通通知和打开应用方式不需要额外 Ability。如果需要在应用进程不存在时接收 HarmonyOS 后台自定义消息，还需要按照极光文档配置：

- `PushMessage.json`。
- `proxyData` 和 `ohos.permission.WRITE_PRIVACY_PUSH_DATA`。
- `PushMessageAbility`。
- `action.ohos.push.listener`。

同一个应用只能有一个 Ability 声明 `action.ohos.push.listener`。

## 9. 验证清单

### 首次安装

- 启动时只显示服务协议与隐私政策。
- 隐私协议上方不出现系统通知权限弹窗。
- 登录成功进入首页后出现通知权限弹窗。
- 同意权限后能获取非空 RegistrationID。
- `serialNo` alias 设置成功。

### 环境切换

- `dev/test/custom` 日志打印测试 AppKey。
- `product` 日志打印正式 AppKey。
- 切换环境时先删除旧 alias，再退出登录。
- 重新登录进入首页后使用新 AppKey setup 并绑定 alias。
- 重复进入首页不重复注册事件监听。

### 通知

- 前台、后台通知能正常到达。
- 冷启动点击通知能正确路由。
- 应用存活时再次点击通知能正确路由。
- 测试和正式后台发送的消息只到达对应环境客户端。

## 10. 常见问题

### 通知权限为什么覆盖隐私协议？

在 Splash 或隐私同意后立即调用了 `setup()`。鸿蒙插件会在 `setup()` 内自动申请通知权限。应确保唯一 setup 调用位于首页。

### `setAuth(false)` 为什么没效果？

当前 `jpush_flutter dev-3.x` 的 HarmonyOS 实现没有实现 `setAuth()`，它只是打印未实现日志。隐私控制必须通过“同意前不调用 setup”实现。

本项目同时需要对齐 Android 的通知权限弹窗时机：Android 在进入首页 `MainActivity` 后才单独申请 `POST_NOTIFICATIONS`，因此 HarmonyOS 也把 `setup()` 放到首页执行，使系统通知权限弹窗出现在登录成功进入首页之后，而不是覆盖服务协议与隐私政策弹窗。

Android 虽然在 `Application.onCreate()` 中初始化极光，但它可以这样做，是因为 Android 的 SDK 初始化、隐私授权和系统通知权限是相互独立的：首次启动先调用 `JCollectionAuth.setAuth(false)` 禁止数据采集，再执行 `JPushInterface.init()` 提前建立推送基础能力；用户同意隐私协议后调用 `setAuth(true)`；Android 13 及以上的 `POST_NOTIFICATIONS` 则直到进入 `MainActivity` 才申请。当前 HarmonyOS Flutter 插件会在 `setup()` 内同时初始化 SDK并申请通知权限，又无法通过 `setAuth(false)`控制隐私授权，所以不能直接照搬 Android 在 App 启动阶段初始化的写法，只能将整个 `setup()` 延迟到首页。

### 为什么没有 RegistrationID？

依次检查 SDK 是否已经 setup、通知/网络状态、`client_id`、Push Kit、签名指纹、包名和极光控制台 HarmonyOS 配置。

### 为什么切换环境后仍收到旧环境消息？

检查是否先删除旧 alias，以及重新进入首页时日志中的 AppKey 是否已经变化。不要在退出登录前后保留旧环境 alias。

## 11. 参考资料

- [极光 HarmonyOS SDK 集成指南](https://docs.jiguang.cn/jpush/client/HarmonyOS/hmos_guide)
- [jpush-flutter-plugin](https://github.com/jpush/jpush-flutter-plugin)
