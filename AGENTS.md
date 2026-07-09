# Agent 开发指南

本文档供 AI Agent 与协作者查阅：常见陷阱、正确写法，以及与本项目 **Flutter ↔ Go BFF ↔ Supabase** 架构相关的约束。

> **工作区总览**（Flutter + Go 双仓库）：[my_go_study/AGENTS.md](../my_code_study/my_go_study/AGENTS.md) §一  
> **后端交互完整说明**：[docs/BACKEND_INTEGRATION.md](docs/BACKEND_INTEGRATION.md)

---

## 目录

1. [HTTP / 后端交互](#http--后端交互)
2. [认证与会话](#认证与会话)
3. [Realtime WebSocket](#realtime-websocket)
4. [GetX / Obx 响应式 UI](#getx--obx-响应式-ui)
5. [Flutter 拖动排序](#flutter-拖动排序longpressdraggable)
6. [鸿蒙（OpenHarmony）三方库](#鸿蒙-openharmony-三方库)
7. [视频播放页沉浸式](#视频播放页沉浸式)

---

## HTTP / 后端交互

### 架构（当前）

- Flutter **仅通过 HTTP** 访问 **my_go_study**（Go BFF），**不**在业务层直连 Supabase SDK。
- 登录/注册：`POST /api/v1/user/*` → Go 代理 **Supabase Auth** → 返回 `access_token`。
- 业务接口（如二手车）：`GET /api/v1/transactions` → Go 校验 **Supabase JWT** → Supabase PostgREST + RLS。
- 分层：`ViewModel → Repository → Api → HttpManager → ResultModel<T>`。

### 初始化顺序（壳工程）

```
EnvironmentSession.register()
AppHttpBootstrap.initialize(headerProvider: AuthHeaderProvider())
AuthSession.register()   // BackendAuthService，非 Mock 时
```

环境切换时必须 `AppHttpBootstrap.reinitialize()`（见 `lib/main.dart`）。

### ResultModel 信封

```json
{ "code": 0, "message": "success", "data": { ... }, "timestamp": 1704067200 }
```

- 列表 `data`：`{ "list": [...], "pagination": { ... } }` 或 Flutter 兼容 `{ "items": [...] }`。
- Api converter：`ResultModel.listPage` / `ResultModel.object`（见 `module_http`）。
- **禁止**在 UI 层直接依赖 `ResultModel`；Repository 解包为 `PageResult` 或实体。

### 常见陷阱

| 问题 | 原因 | 修复 |
|------|------|------|
| `FormatException: Invalid HTTP header` | `X-App-Env` 用了中文 | 使用 `AppEnv.name`（`test`/`staging`/`production`） |
| 登录显示 `Internal Server Error` | Dio 未解析 4xx body | 已用 `validateStatus < 600` + `BackendResponseParser` |
| 模拟器连不上 `127.0.0.1:8080` | 网络隔离 | Android/鸿蒙自动映射 `10.0.2.2`；真机用局域网 IP |
| 二手车 401 | token 过期或未登录 | 须经 Go 后端登录获取 access_token |
| `.env` 修改不生效 | 热重载不读 define | **Hot Restart** 或重新 `flutter run` |

### 参考文件

- `packages/commons/network/lib/http/app_http_bootstrap.dart`
- `packages/commons/network/lib/http/backend_response_parser.dart`
- `packages/commons/network/lib/api/result_model.dart`
- `packages/features/home/lib/home/api/transaction_api.dart`
- `docs/BACKEND_INTEGRATION.md`

---

## 认证与会话

### 默认实现

| 开关 | 实现 | 说明 |
|------|------|------|
| `USE_MOCK_AUTH=true` | `MockAuthService` | 本地调试，不请求 Go |
| `USE_MOCK_AUTH=false` | `BackendAuthService` | Flutter → Go → Supabase |

### 登录约定

- 请求体 `username` = **完整邮箱**；密码 ≥ **6 位**。
- 成功：`UserService.setUser`，token 为 Supabase `access_token`。
- 错误映射见 `UserAuthApi._mapFailure`：`AccountNotRegisteredFailure`(10003)、`InvalidCredentialsFailure`(10002) 等。

### 需登录功能入口

```dart
if (AuthSession.isLoggedIn) {
  await Get.toNamed(targetRoute);
} else {
  await AuthNavigation.openLogin(redirectRoute: targetRoute);
}
```

参考：`packages/features/home/lib/home/navigation/used_car_navigation.dart`。

### 密钥与 Git

- **`.env` 须入库**，仅含 `USE_MOCK_AUTH` 开关；新成员可复制 `.env.example`。
- 仅 **`.env.local`** 等本地覆盖文件不入库（已在 `.gitignore`）。
- **Supabase 密钥仅配置在 Go 后端** `my_go_study` 的 `.env` 或 `configs/`、`SUPABASE_*` 环境变量；Flutter 不持有、不直连。

---

## GetX / Obx 响应式 UI

### 问题现象

```
[Get] the improper use of a GetX has been detected.
You should only use GetX or Obx for the specific widget that will be updated.
```

通常表示 `Obx` / `GetX` 的 builder **在 build 期间没有读取任何 `.obs` 变量**。

### 正确写法

```dart
// ✅ 在 Obx 内读取 .value / .toList() / .length
Obx(() {
  final items = controller.functions.toList();
  return MineReorderableFunctionGrid(
    key: ValueKey(items.map((e) => e.id).join(',')),
    items: items,
    onReorder: controller.reorderFunction,
    onItemTap: controller.onFunctionTap,
  );
});

// ✅ 读取 Rxn / Rx 的 .value
Obx(() {
  final profile = controller.profile.value;
  if (profile == null) return const SizedBox.shrink();
  return ProfileHeader(data: profile);
});
```

```dart
// ❌ builder 内未订阅 obs
Obx(() => MyGrid(items: controller.functions));

// ❌ 在 Obx 外读取 obs
final list = controller.functions;
Obx(() => MyGrid(items: list));
```

### 规则清单

1. **`Obx` builder 必须是块级函数**，在 return 之前读取 obs。
2. **先把 `RxList` 快照为普通 `List`** 再传给子组件。
3. **列表重排**后给 StatefulWidget 加 `ValueKey`（id 拼接）。
4. **父子响应不同 obs** 时各包一层 `Obx`。
5. **无 obs 依赖不要包 Obx**。

### 参考实现

- `packages/features/settings/lib/mine/widgets/mine_function_section_widget.dart`
- `packages/features/settings/lib/mine/widgets/mine_header_widget.dart`
- `packages/features/home/lib/home/view/all_services_page.dart`

---

## Flutter 拖动排序（LongPressDraggable）

### 问题现象

```
'!_debugDoingThisLayout': is not true
'hasSize': is not true
Cannot hit test a render box with no size
```

### 修复要点

1. **`feedback` 必须有明确宽高**；避免 `Expanded`/`Flexible` 导致无尺寸。
2. **不要在 `DragTarget.onMove` 里 `setState`**；用 `candidateData.isNotEmpty` 高亮。
3. **拖动状态变更**用 `SchedulerBinding.instance.addPostFrameCallback` 延迟 `setState`。
4. **宫格 reorder** 优先 `childDragAnchorStrategy`；`feedback` 用 `Transform.scale(0.94)` + 明确 `SizedBox`。

参考：`packages/features/settings/lib/mine/widgets/mine_reorderable_function_grid.dart`

---

## 鸿蒙（OpenHarmony）三方库

### Flutter SDK

使用 [CPF-Flutter/flutter_flutter](https://gitcode.com/CPF-Flutter/flutter_flutter/tree/3.35.8-ohos-1.0.1) **3.35.8-ohos-1.0.1**。IDE 指向 `.fvm/versions/custom_3.35-ohos`，**不要**用标准 pub.dev Flutter 编此项目。

### 原则

带原生能力的库**必须**有鸿蒙适配后再引入；根 `pubspec.yaml` `dependency_overrides` 指向 CPF git 源。

### 依赖写法

1. Feature 模块 `pubspec.yaml` 保持 pub.dev 语义化版本。
2. 根 `dependency_overrides` 统一鸿蒙 git 源（federated 插件需同时 override 主包与 `*_ohos`）。
3. `flutter pub get` 后检查 `ohos/entry/oh-package.json5` har 依赖。

### 本项目已接入

- `ImagePickerUtils` / `MediaSourceBottomSheet` / `image_picker_ohos`
- `permission_handler_ohos`
- `ScanUtils` / `scan`（git override）

详见根 [`pubspec.yaml`](pubspec.yaml) 与各 feature 模块 `pubspec.yaml`。

---

## 视频播放页沉浸式

### 要求

以**视频播放为主**的页面须：

1. **隐藏状态栏内容**：`SystemUiMode.immersiveSticky`。
2. **画面铺满顶部**，不为状态栏单独留白。
3. **离开播放页**恢复 `ImmersiveHelper.apply(immersive: true)`。

### 正确写法

用 `VideoPlaybackImmersiveScope` 包裹播放页根节点；顶部内嵌播放区用 `AppSafeInsets.top(context)` 定位返回按钮；底部用 `AppVideoControlsBar`。

```dart
// ❌ 错误：沉浸式下为状态栏留白会出现顶部黑条
Positioned.fill(top: MediaQuery.paddingOf(context).top, child: video),
```

### 参考实现

- `packages/commons/ui/lib/layout/video_playback_immersive_scope.dart`
- `packages/commons/toolkit/lib/utils/app_video_controls_bar.dart`
- `packages/features/video/lib/dubbing/widgets/playable_video_header.dart`
- `packages/features/video/lib/short_video/view/short_video_play_page.dart`

---

## Realtime WebSocket

### 架构

Flutter `module_realtime` → Go BFF（非直连 Supabase Realtime）：

```text
登录 token → POST /api/v1/realtime/ws-ticket → WebSocket /realtime/v1/connect
           → auth → sub → 收 event / ping-pong
重连       → POST /api/v1/realtime/sync（补拉 sinceSeq 之后事件）
```

### 配置

| 项 | 位置 | 说明 |
|----|------|------|
| `useMockGateway` | `realtime_config.dart` | `false` = 连 Go；`true` = 进程内 Mock |
| `wsBaseUrl` | `env_config.dart` | 参考地址；实际用 ticket 返回的 `wsUrl` |
| 模拟器 WS | `backend_ws_config.dart` | `127.0.0.1` → `10.0.2.2` |

### 心跳（应用层）

- 间隔 25s 发 `{type:"ping"}`，10s 内须收到同 id 的 `pong`
- 连续 2 次超时 → 触发重连（指数退避 1s～60s）

### 常用 API

```dart
final client = Get.find<AppRealtimeClient>();
await client.subscribeTopics([RealtimeTopics.sysNotify]);
client.watchEvents(eventName: 'sys.notify.show').listen((e) { /* Banner */ });
await client.sendEvent(topic: RealtimeTopics.presenceBulk, eventName: 'presence.report', payload: {});
```

### 调试

**DoKit（DoraemonKit）**：仅 **Debug 构建**启用（`lib/bootstrap/app_runner_debug.dart`）；Profile/Release 不加载。启动后屏幕边缘有悬浮球，可查看日志、网络、路由等；「业务专区」含链接/Realtime/IM/弹框调度入口。

设置页仍保留 **开发调试** 列表（`/settings/*_debug`）。Go 端推送测试：`POST /api/v1/realtime/push`（需 Bearer token）。

**完整协议、JSON 示例、curl/Python 联调**：Go 仓库 [docs/realtime-websocket.md](../../my_code_study/my_go_study/docs/realtime-websocket.md)

### 参考文件

- `packages/infrastructure/dokit/` — vendored DoKit（Dart 3 适配）
- `packages/infrastructure/dokit_bootstrap/` — BizKit 注册
- `lib/bootstrap/app_runner_debug.dart`
- `packages/infrastructure/realtime/lib/client/app_realtime_client_impl.dart`
- `packages/infrastructure/realtime/lib/connection/heartbeat_scheduler.dart`
- `packages/infrastructure/realtime/lib/config/realtime_config.dart`

---

## Git 提交

创建 commit 时**不要**添加 `Co-authored-by: Cursor` 等 Agent 尾注；只写与变更相关的标题和正文。
