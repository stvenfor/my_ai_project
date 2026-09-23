# Agent 开发指南

本文档供 AI Agent 与协作者查阅：**四层目录边界**、模块化约定、常见陷阱、正确写法，以及 **Flutter ↔ Go BFF ↔ Supabase** 约束。

> **工作区总览**（Flutter + Go 双仓库）：[my_go_study/AGENTS.md](../my_code_study/my_go_study/AGENTS.md) §一  
> **双仓编码 Playbook**：[docs/coding-playbook-dual-repo.md](docs/coding-playbook-dual-repo.md)（一键提示词；全文真相源在 Go 仓）  
> **分层架构详解**：[docs/architecture.md](docs/architecture.md)  
> **模块化开发指南**：[docs/MODULE_ARCHITECTURE.md](docs/MODULE_ARCHITECTURE.md)  
> **后端交互完整说明**：[docs/BACKEND_INTEGRATION.md](docs/BACKEND_INTEGRATION.md)

### 开新模块一键提示词

```text
# 规划（先不写码）
结合双仓设计 <模块>：术语 Avoid → Go API/权限 → Flutter 对标页与四层边界 → Slice backlog；等我批 Brief。
见 docs/coding-playbook-dual-repo.md

# 执行（Brief 已批）
只改白名单；dart analyze 触及包；UI 对标 Brief；acceptance Partial 可；commit/push 等我指令。
```

---

## 目录

1. [目录分层与依赖](#目录分层与依赖)
2. [模块化与启动](#模块化与启动)
3. [HTTP / 后端交互](#http--后端交互)
4. [认证与会话](#认证与会话)
5. [GetX / Obx 响应式 UI](#getx--obx-响应式-ui)
6. [Realtime WebSocket](#realtime-websocket)
7. [Flutter 拖动排序](#flutter-拖动排序longpressdraggable)
8. [鸿蒙（OpenHarmony）三方库](#鸿蒙-openharmony-三方库)
9. [视频播放页沉浸式](#视频播放页沉浸式)

---

## 目录分层与依赖

本项目是 **Flutter 模块化 Monolith**，仓库根下四个**同级**目录层（**已无** `packages/`、`infrastructure/`）：

```text
.
├── lib/              # 壳工程：启动、模块清单、Splash/Main、壳级路由
├── commons/          # 必选基础（6 个 package）
├── components/       # 可选组合（按需引入）
└── features/         # 业务模块（12 个 module_*）
```

**依赖方向**：

```text
lib → features / components / commons
features → components / commons
components → commons
```

**硬边界**（违反会导致编译耦合或循环依赖）：

| 禁止 | 替代做法 |
|------|----------|
| `commons → components/features` | 契约放 `module_core`，实现放 feature/component |
| `components → features` | 登录态用 `AuthLifecycle` / `UserService` / `SessionGuardService` |
| feature 互引页面/ViewModel | 路由跳转、`module_core` 抽象服务、EventBus |

### commons（目录名 ≠ pubspec 名）

| 目录 | package | import |
|------|---------|--------|
| `commons/core/` | `module_core` | `package:module_core/core.dart` |
| `commons/network/` | `module_http` | `package:module_http/module_http.dart` |
| `commons/storage/` | `module_global_cache` | `package:module_global_cache/module_global_cache.dart` |
| `commons/toolkit/` | `module_utils` | `package:module_utils/module_utils.dart` |
| `commons/ui/` | `module_common_ui` | `package:module_common_ui/module_common_ui.dart` |
| `commons/wys_router/` | `wys_router` | `package:wys_router/wys_router.dart` |
| `commons/wys_network/` | `wys_network` | （与 `module_http` 并存） |
| `commons/wys_account/` | `wys_account` | **DEPRECATED**（ADR 0009）；Session Owner 为 `module_auth`，勿初始化 |
| `commons/wys_common/` | `wys_common` | （与 ui/utils 并存） |

**commons 内部分层**：L0 `core`/`toolkit` → L1 `network`/`storage`/`wys_router` → L2 `ui`（`ui` 依赖 `core` + `toolkit` + `wys_router`）。`wys_network` / `wys_common` 为并存栈，新业务优先 `module_*`；`wys_account` 已废弃（ADR 0009），勿接入。

### components（可选，根 pubspec 按需引入）

| 目录 | package | 职责 |
|------|---------|------|
| `components/realtime/` | `module_realtime` | Go BFF WebSocket Realtime |
| `components/linking/` | `module_linking` | 深链、推送、隐私 consent |
| `components/rongcloud_im/` | `module_rongcloud_im` | 融云 IM |
| `components/bluetooth/` | `module_bluetooth` | BLE demo |
| `components/dokit/` | `dokit` | Vendored DoKit |
| `components/dokit_bootstrap/` | `module_dokit_bootstrap` | Debug 壳 DoKit 注册 |
| `components/wys_push/` | `wys_push` | 极光推送 |
| `components/wys_face_verify/` | `wys_face_verify` | 腾讯云人脸核身 |
| `components/wys_login_share_pay/` | `wys_login_share_pay` | 微信/支付宝 |

根 `pubspec.yaml` 当前直接依赖：linking、realtime/rongcloud_im、dokit_bootstrap，以及 `wys_*`；bluetooth 经 `module_settings` 间接使用。

### features（12 个业务包）

| moduleId | 目录 | package | 主 Tab |
|----------|------|---------|--------|
| home | `features/home/` | `module_home` | 首页 (0) |
| chat | `features/chat/` | `module_chat` | 聊天 (1) |
| community | `features/community/` | `module_community` | 社区 (2) |
| settings | `features/settings/` | `module_settings` | 我的 (3) |
| auth | `features/auth/` | `module_auth` | — |
| ai | `features/ai/` | `module_ai` | —（AI 小石头 SSE） |
| video | `features/video/` | `module_video` | — |
| classroom | `features/classroom/` | `module_classroom` | — |
| music | `features/music/` | `module_music` | — |
| live | `features/live/` | `module_live` | — |
| pay | `features/pay/` | `module_pay` | — |
| friend | `features/friend/` | `module_friend` | — |
| bfui | `features/bfui/` | `module_bfui` | — |

**允许的跨 feature 依赖**（最小集，勿随意新增）：

| 模块 | 可依赖 |
|------|--------|
| home | auth、music |
| settings | auth + linking/realtime/im/bluetooth |
| chat | rongcloud_im |
| live | realtime |
| 其余 | 仅 commons + route |

### path 引用约定

```yaml
# 根 pubspec.yaml
module_core:
  path: ./commons/core

# features/xxx/pubspec.yaml（以 home 为例）
module_core:
  path: ../../commons/core
module_auth:
  path: ../auth
module_realtime:
  path: ../../components/realtime
```

详见 [commons/README.md](commons/README.md)、[components/README.md](components/README.md)。

---

## 模块化与启动

### lib 壳工程关键文件

| 文件 | 职责 |
|------|------|
| `lib/main.dart` | `AppInitializer.init()`：工具/DB/HTTP/Auth → `ModuleRegistry` → Linking/IM/Realtime |
| `lib/config/module_manifest.dart` | **模块开关**：注释 import + `buildEnabledModules()` 列表项即可裁剪 |
| `lib/app/app_pages.dart` | 合并壳路由 + `ModuleRegistry.collectRoutes()` |
| `lib/pages/main_page.dart` | 从 `ModuleRegistry.collectMainTabs()` 构建 Tab（`IndexedStack`） |
| `lib/route/app_route_container.dart` | 壳路由：`/` Splash、`/main` Tab 宿主 |
| `commons/wys_router/lib/src/route/route_path.dart` | **全项目路由常量** |

### 启动顺序（`AppInitializer.init`）

```text
ModuleUtilsInitializer → SpManager/AppDatabase
→ EnvironmentSession.register()
→ AppHttpBootstrap.initialize()      # Go BFF HTTP
→ AuthSession.register()
→ UiKitInitializer / WebKitInitializer
→ ModuleRegistry.registerAll(buildEnabledModules())
→ ModuleRegistry.bootstrap()         # 各模块 onRegister
→ AppBinding + LinkingBinding + collectBindings()
→ LinkingInitializer / ImInitializer / RealtimeInitializer (deferred)
→ runApp(App())                      # initialRoute: /
```

环境切换时必须 `AppHttpBootstrap.reinitialize()`（见 `lib/main.dart` `_wireEnvironmentHttpRefresh`）。

### FeatureModule 契约

每个 feature 在 `lib/*_module.dart` 实现 `FeatureModule`（`commons/wys_router`）：

```dart
abstract class FeatureModule {
  String get moduleId;
  Map<String, WidgetBuilder> routes();
  ModuleTabItem? get mainTab => null;   // Tab 模块才实现
  Bindings? createBinding() => null;
  Future<void> onRegister(ModuleHostContext context) async {}
}
```

**模块内 MVVM 分层**（以 `module_home` 为模板）：

```text
view/ → controller|viewmodel/ → repository/ → api/ → model/
```

- 路由常量用 `RoutePath`，**禁止**在 feature 内硬编码路径字符串
- Binding 注册 ViewModel/Controller；页面优先 `GetView<T>`
- 请求逻辑自包含在模块内，不依赖主工程 `lib/`

### 路由与 Tab

1. `AppRouteContainer.installShellRouters()` — Splash / Main
2. `ModuleRegistry.collectRoutes()` — 各模块 `routes()`
3. `MainPage`：`collectMainTabs()` 按 `order` 排序；**`pageBuilder()` 只调用一次并缓存**（勿在每次 `build` 新建 Tab 页）

### 模块独立运行

```bash
flutter run -t features/home/lib/main_dev.dart
```

使用 `ModuleStandaloneRunner.run(XxxModule())`；模块在 `onRegister` 中自行初始化 HTTP。

### 新建/修改模块 Checklist

1. 在 `features/<name>/` 创建 package，实现 `FeatureModule`
2. 根 `pubspec.yaml` + `lib/config/module_manifest.dart` 注册
3. 新增路由写入 `RoutePath` + 模块 `routes()`
4. path 依赖仅指向 `commons/`、`components/`、允许的 feature
5. **不要**在 `components/` 或 `commons/` 中 import feature 页面

---

## HTTP / 后端交互

### 架构（当前）

- Flutter **仅通过 HTTP** 访问 **my_go_study**（Go BFF），**不**在业务层直连 Supabase SDK。
- 登录/注册：`POST /api/v1/user/*` → Go 代理 **Supabase Auth** → 返回 `access_token`。
- 业务接口（如二手车）：`GET /api/v1/transactions` → Go 校验 **Supabase JWT** → Supabase PostgREST + RLS。
- 分层：`View → ViewModel → Repository → Api → HttpManager → ResultModel<T>`。

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
| 模拟器连不上 `127.0.0.1:8080` | 网络隔离 | Android/鸿蒙自动映射 `10.0.2.2`；真机用 IDE「LAN 真机」或 `./scripts/run_app.sh --lan`（`.env.lan` + `BACKEND_HOST`；手册：Go `docs/dual-end-lan-startup.md`） |
| 二手车 401 | token 过期或未登录 | 须经 Go 后端登录获取 access_token |
| `.env` 修改不生效 | 热重载不读 define | **Hot Restart** 或重新 `flutter run` |

### 参考文件

- `commons/network/lib/http/app_http_bootstrap.dart`
- `commons/network/lib/http/backend_response_parser.dart`
- `commons/network/lib/api/result_model.dart`
- `features/home/lib/home/api/transaction_api.dart`
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
- 开发环境手机号 OTP（Go 非 release）：测试号 `13400000000`，验证码 `123456`（ADR 0010）；生产短信未开放。
- Session Owner 为 `module_auth`；`wys_account` 已废弃（ADR 0009），勿再初始化。

### components 读登录态

`components` **不得**依赖 `module_auth`。读登录/用户用：

- `AuthLifecycle.isLoggedIn` / `AuthLifecycle.currentUser` / `onAfterLogin` / `onAfterLogout`
- `SessionGuardService`（抽象在 `module_core`，实现由 `AuthSession` 注册）

契约：`commons/core/lib/service/auth_lifecycle.dart`、`session_guard_service.dart`。  
实现：`features/auth/lib/session/auth_session_guard_service.dart`。

### 需登录功能入口

```dart
if (AuthSession.isLoggedIn) {
  await Get.toNamed(targetRoute);
} else {
  await AuthNavigation.openLogin(redirectRoute: targetRoute);
}
```

参考：`features/home/lib/home/navigation/used_car_navigation.dart`。

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

另一类：主 Tab **底部栏在、中间白屏**——多为页面未用 `GetView`/`Obx` 订阅，控制器被 SmartManagement 回收后 `fenix` 重建，旧 `ever` 仍挂旧实例。

### 主 Tab / 列表页写法

```dart
// ✅ GetView + Obx：controller 有引用，加载完成后自动重建
class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      body: Obx(() {
        final data = controller.dashboard.value;
        final error = controller.errorMessage.value;
        if (data == null) {
          if (error != null) return ErrorRetry(...);
          return const Center(child: CircularProgressIndicator());
        }
        return HomeDashboard(data: data);
      }),
    );
  }
}
```

```dart
// ❌ StatefulWidget + ever → setState：控制器可被回收，页面停在空占位
// ❌ data == null 时用 SizedBox.shrink()：加载失败像「白屏」
```

`MainPage` 的 Tab `pageBuilder()` **只调用一次并缓存**；每次 `build` 新建 `HomePage()` 会反复 dispose/init，加剧生命周期问题。参考：`lib/pages/main_page.dart`、`features/home/lib/home/view/home_page.dart`。

### Obx 订阅写法

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
```

```dart
// ❌ builder 内未订阅 obs
Obx(() => MyGrid(items: controller.functions));

// ❌ 在 Obx 外读取 obs
final list = controller.functions;
Obx(() => MyGrid(items: list));
```

### 规则清单

1. **依赖 obs 的页面优先 `GetView<T>` + `Obx`**，不要用 `ever` + `setState` 顶替。
2. **`Obx` builder 必须是块级函数**，在 return 之前读取 obs。
3. **先把 `RxList` 快照为普通 `List`** 再传给子组件。
4. **列表重排**后给 StatefulWidget 加 `ValueKey`（id 拼接）。
5. **父子响应不同 obs** 时各包一层 `Obx`。
6. **无 obs 依赖不要包 Obx**。
7. **加载中**用明确占位（Progress / shimmer）；避免空 `SizedBox.shrink()` 伪装成白屏。

### 参考实现

- `features/home/lib/home/view/home_page.dart`
- `features/settings/lib/mine/view/mine_page.dart`
- `features/settings/lib/mine/widgets/mine_function_section_widget.dart`
- `features/settings/lib/mine/widgets/mine_header_widget.dart`
- `features/home/lib/home/view/all_services_page.dart`

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

- `components/dokit/` — vendored DoKit（Dart 3 适配）
- `components/dokit_bootstrap/` — BizKit 注册
- `lib/bootstrap/app_runner_debug.dart`
- `components/realtime/lib/client/app_realtime_client_impl.dart`
- `components/realtime/lib/connection/heartbeat_scheduler.dart`
- `components/realtime/lib/config/realtime_config.dart`

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

参考：`features/settings/lib/mine/widgets/mine_reorderable_function_grid.dart`

---

## 鸿蒙（OpenHarmony）三方库

对照组织：[CPF-Flutter](https://gitcode.com/CPF-Flutter)（SDK / packages / 三方适配列表）。

### Flutter SDK

使用 [CPF-Flutter/flutter_flutter](https://gitcode.com/CPF-Flutter/flutter_flutter) **3.35.x-ohos** 稳定线。IDE 指向 `.fvm/versions/custom_3.35-ohos`，**不要**用标准 pub.dev Flutter 编鸿蒙目标。

### 原则

带原生能力的库**必须**有鸿蒙适配后再引入。

### 依赖写法

1. Feature / commons 模块 `pubspec.yaml` 仍写 **pub.dev 语义化版本**。
2. **已适配 Flutter 3.35 的 OHOS 库放在根 `dependencies`（git）**。只声明主包；`*_ohos` 由主包 path 带入。
3. 官方仓可用：
   - [CPF-Flutter](https://gitcode.com/CPF-Flutter)（`flutter_plus_plugins`、独立插件仓）
   - [openharmony-tpc/flutter_packages](https://gitcode.com/openharmony-tpc/flutter_packages)
4. features/commons 仍写 pub.dev 时，根 `dependency_overrides` 需**镜像同名 git 条目**做 hosted↔git 同源消解；另保留 `rxdart` / `screen_brightness_ios` 等非鸿蒙钉选。
5. `flutter pub get`（OHOS Flutter SDK）后检查 `ohos/entry/oh-package.json5` 是否写入 har。

```yaml
# plus 插件示例
connectivity_plus:
  git:
    url: https://gitcode.com/CPF-Flutter/flutter_plus_plugins.git
    path: packages/connectivity_plus/connectivity_plus
    ref: br_connectivity_plus-v6.1.0_ohos

# flutter_packages 示例（openharmony-tpc）
path_provider:
  git:
    url: https://gitcode.com/openharmony-tpc/flutter_packages.git
    path: packages/path_provider/path_provider
    ref: br_path_provider-v2.1.5_ohos
```

### 本项目根工程已接入（3.35）

| 能力 | 主包 | 来源 / 分支 |
|------|------|-------------|
| 选图 | `image_picker` | openharmony-tpc / `br_image_picker-v1.2.1_ohos` |
| 路径 | `path_provider` | openharmony-tpc / `br_path_provider-v2.1.5_ohos` |
| SP | `shared_preferences` | openharmony-tpc / `br_shared_preferences-v2.5.4_ohos` |
| 扫码 | `scan` | CPF `fluttertpc_scan` / `master` |
| 权限 | `permission_handler` | CPF / `br_v12.0.1_ohos` |
| SQLite | `sqflite` | CPF / `br_v2.4.2_ohos` |
| 音频 | `audioplayers` | CPF / `br_v6.5.1_ohos` |
| WebView | `flutter_inappwebview` | CPF / `br_v6.1.5_ohos` |
| 网络状态 | `connectivity_plus` | CPF plus_plugins / `br_connectivity_plus-v6.1.0_ohos` |
| 设备信息 | `device_info_plus` | CPF plus_plugins / `br_device_info_plus-v12.3.0_ohos` |
| 包信息 | `package_info_plus` | CPF plus_plugins / `br_package_info_plus-v9.0.0_ohos` |
| 常亮 | `wakelock_plus` | CPF / `br_v1.4.0_ohos` |
| 视频解码 | `video_player` | openharmony-tpc / `br_video_player-v2.10.0_ohos` |
| 社区播放控件 | `chewie` | CPF `fluttertpc_chewie` / `br_v1.13.0_ohos` |

`video_player_ohos` 误将 codegen `pigeon` 写进 `dependencies`（与 `json_serializable` 的 analyzer 冲突）。根工程用 `packages/pigeon_runtime_stub` **override** 顶掉；插件 `lib` 已含 `messages.g.dart`，运行时不需要真 pigeon。

### 暂缓 / 仍用 pub.dev

- `flutter_blue_plus`（蓝牙 demo）
- `screen_brightness` / `volume_controller`（短视频控制条）

详见根 [`pubspec.yaml`](pubspec.yaml)。

---

## 视频播放页沉浸式

### 要求

以**视频播放为主**的页面须：

1. **隐藏状态栏内容**：`SystemUiMode.immersiveSticky`。
2. **画面铺满顶部**，不为状态栏单独留白。
3. **离开播放页**恢复 `ImmersiveHelper.apply(immersive: true)`。

### 正确写法

用 `VideoPlaybackImmersiveScope` 包裹播放页根节点；顶部内嵌播放区用 `AppSafeInsets.top(context)` 定位返回按钮。

- 社区：`VideoPlayPage` → Chewie（controls + 全屏横竖屏）
- 小视频：`ShortVideoPlayerKit` + `AppVideoControlsBar` / 手势（不共用 Chewie）
- 内嵌头图等：底部可用 `AppVideoControlsBar`

```dart
// ❌ 错误：沉浸式下为状态栏留白会出现顶部黑条
Positioned.fill(top: MediaQuery.paddingOf(context).top, child: video),
```

### 参考实现

- `commons/ui/lib/layout/video_playback_immersive_scope.dart`
- `commons/toolkit/lib/utils/app_video_controls_bar.dart`
- `features/video/lib/dubbing/widgets/playable_video_header.dart`
- `features/video/lib/short_video/view/short_video_play_page.dart`

---

## Git 提交

创建 commit 时**不要**添加 `Co-authored-by: Cursor` 等 Agent 尾注；只写与变更相关的标题和正文。
