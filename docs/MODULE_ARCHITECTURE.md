# Flutter 模块化 + MVVM 架构使用文档

本文档说明 `module_sample` 的项目结构、模块配置方式、MVVM 分层规范、独立运行方法，以及如何安全地启用/禁用模块。

> **三层架构总览**（lib / commons / features）：详见 [architecture.md](./architecture.md)

---

## 1. 总体架构

**lib / commons / features 三层物理同级**，辅助包（route、infrastructure）留在 `packages/`：

```
module_sample
├── lib/                              # 壳工程层
├── commons/                          # 公共能力层
│   ├── core/                         # module_core — 契约 + 跨模块模型
│   ├── network/                      # module_http — Dio + AppHttpBootstrap
│   ├── storage/                      # module_global_cache — sqflite、AppSettings
│   ├── toolkit/                      # module_utils — 第三方工具封装（唯一安装点）
│   └── ui/                           # module_common_ui — 主题、Loading/Refresh、BaseViewModel
├── features/                         # 业务模块层
│   └── home / settings / auth / chat / …
└── packages/                         # 辅助包
    ├── route/                        # module_route — FeatureModule + ModuleRegistry
    └── infrastructure/               # realtime / linking / IM / dokit
```

> 详见 [architecture.md §1](./architecture.md#1-总体定位)。

**设计原则：**

| 原则 | 实现方式 |
|------|----------|
| 模块可插拔 | `module_manifest.dart` 注释 import + 列表项 |
| MVVM 分层 | View(GetView) / ViewModel(GetxController) / Repository / Api |
| 请求在模块内 | 各模块自有 `api/` + `repository/`，不依赖主工程 |
| 独立运行 | 各模块 `lib/main_dev.dart` + `ModuleStandaloneRunner` |
| 主工程零业务耦合 | `MainPage` 从 `ModuleRegistry` 读取 Tab，不硬编码页面 |

---

## 2. 标准模块目录结构

以 `module_home` 为参考模板：

```
module_home/
├── pubspec.yaml
├── lib/
│   ├── main_dev.dart              # 独立运行入口
│   ├── home_module.dart           # ★ FeatureModule 实现（模块唯一注册点）
│   ├── module_home.dart           # 对外 export
│   └── home/
│       ├── view/                  # V - UI 层（GetView / StatelessWidget）
│       │   └── home_page.dart
│       ├── viewmodel/             # VM - 状态与业务编排
│       │   └── home_viewmodel.dart
│       ├── repository/            # 数据仓库（组合 Api、缓存）
│       │   └── home_repository.dart
│       ├── api/                   # 网络请求 + HTTP 配置
│       │   ├── home_api.dart
│       │   └── home_http_config.dart
│       └── model/                 # 数据模型（可用 json_serializable）
│           └── banner_model.dart
```

### 2.1 各层职责

| 层级 | 命名 | 职责 |
|------|------|------|
| **View** | `*_page.dart` | 只负责 UI 渲染、用户事件转发给 ViewModel |
| **ViewModel** | `*_viewmodel.dart` | 继承 `BaseViewModel`，管理状态、调用 Repository |
| **Repository** | `*_repository.dart` | 封装数据来源（网络/本地），对 ViewModel 屏蔽 Api 细节 |
| **Api** | `*_api.dart` | 发起 HTTP 请求，仅处理协议与路径 |
| **Model** | `*_model.dart` | 数据结构、JSON 解析 |

### 2.2 Binding（依赖注入）

```dart
// home/view/home_page.dart 内或单独 binding 文件
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeViewModel>(HomeViewModel.new);
  }
}
```

View 使用 `GetView<HomeViewModel>`：

```dart
class HomePage extends GetView<HomeViewModel> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('${controller.banners.length}'));
  }
}
```

### 2.3 FeatureModule（模块注册点）

每个业务模块必须提供一个 `*_module.dart`：

```dart
class HomeModule extends FeatureModule {
  @override
  String get moduleId => 'home';

  @override
  ModuleTabItem? get mainTab => ModuleTabItem(...);  // Tab 模块才需要

  @override
  Bindings? createBinding() => HomeBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
    RoutePath.home: (_) => const HomePage(),
  };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    // 独立运行时初始化 HTTP、注册 Binding
  }
}
```

---

## 3. 主工程如何装配模块

### 3.1 模块清单 — `lib/config/module_manifest.dart`

```dart
import 'package:module_home/home_module.dart';
import 'package:module_chat/chat_module.dart';
// import 'package:module_community/community_module.dart';  // ← 注释 import

List<FeatureModule> buildEnabledModules() {
  return [
    HomeModule(),
    ChatModule(),
    // CommunityModule(),  // ← 注释列表项
    SettingsModule(),
    AuthModule(),
    // ...
  ];
}
```

**禁用模块两步：**

1. 注释 `import 'package:module_xxx/...'`
2. 注释 `buildEnabledModules()` 中对应的 `XxxModule()`

可选：在根 `pubspec.yaml` 注释对应 `module_xxx` 依赖（不注释也能编译，只要 manifest 不引用）。

### 3.2 启动流程

```
main()
  → AppRunner.launch()                    // Debug: DoKit | Release: 直接启动
  → AppInitializer.init()
      → ModuleUtilsInitializer
      → SpManager / AppDatabase
      → EnvironmentSession + AppHttpBootstrap (Go BFF)
      → AuthSession.register()
      → UiKitInitializer / WebKitInitializer
      → ModuleRegistry.registerAll(buildEnabledModules())
      → ModuleRegistry.bootstrap()        // 各模块 onRegister
      → AppBinding + LinkingBinding + 各模块 Binding
      → Linking / IM / Realtime (deferred)
      → AppController.loadSettings()
  → runApp(App())                         // GetMaterialApp
```

### 3.3 Tab 与路由

- **Tab**：`MainPage` 调用 `ModuleRegistry.collectMainTabs()`，按 `order` 排序
- **路由**：`AppPages.routes()` = 壳路由 + `ModuleRegistry.collectRoutes()`
- **路径常量**：统一在 `module_route/lib/route/route_path.dart`

---

## 4. 模块独立运行

任意已实现 `main_dev.dart` 的模块可单独调试：

```bash
# 在模块目录下（需有 pubspec.yaml）
cd module_home
flutter pub get
flutter run -t lib/main_dev.dart

# 或在主工程根目录指定 package
flutter run -t features/home/lib/main_dev.dart
```

独立运行时：

- `ModuleHostContext.standalone()` 传入 `onRegister`
- 模块自行初始化 HTTP（如 `HomeHttpConfig.ensureInitialized()`）
- `ModuleStandaloneRunner.run(XxxModule())` 启动最小 GetMaterialApp

已提供 `main_dev.dart` 的模块：

| 模块 | 入口文件 |
|------|----------|
| module_home | `features/home/lib/main_dev.dart` |
| module_chat | `features/chat/lib/main_dev.dart` |
| module_community | `features/community/lib/main_dev.dart` |
| module_settings | `features/settings/lib/main_dev.dart` |

---

## 5. 网络请求规范

### 5.1 模块内自包含

请求逻辑放在模块的 `api/` 层，**不要**从主工程直接调用业务接口。

```
ViewModel → Repository → Api → HttpManager
```

示例（`module_home`）：

```dart
// api/home_api.dart
class HomeApi {
  Future<List<BannerModel>> fetchBanners() async {
    HomeHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<List<BannerModel>>(...);
    return result.data ?? [];
  }
}
```

### 5.2 HTTP 能力（module_http）

| 能力 | 配置 |
|------|------|
| 超时 | `HttpClientConfig.connectTimeout / receiveTimeout` |
| 日志 | `enableLog: true` → `LogPrintInterceptor` |
| 重试 | `maxRetries: 3` → `RetryInterceptor`（超时/5xx 自动重试） |
| 响应解析 | 实现 `HttpResponseParser`（如 WanAndroid `errorCode` 格式） |

模块独立 HTTP 配置示例：`module_settings/lib/mine/api/mine_http_config.dart`

---

## 6. 本地存储

| 用途 | 模块 | 说明 |
|------|------|------|
| 轻量 KV（主题、语言） | `module_global_cache` | `SpManager` + `AppSettings`（json_serializable） |
| 结构化数据 | `module_global_cache` | `AppDatabase`（sqflite，`cache_entries` 表） |

生成 `AppSettings` 代码：

```bash
cd commons/storage
dart run build_runner build
```

---

## 7. 跨模块共享能力

| 模块 | 用途 |
|------|------|
| `module_utils`（commons/toolkit） | **工具统一入口**：Log/SP/CacheImage/Svg/Lottie/Html/ScreenUtil |
| `module_common_ui`（commons/ui） | 主题、UiKit、BaseViewModel |
| `module_route` | `RoutePath`、`FeatureModule`、`ModuleRegistry` |
| `module_http` | 统一 Dio 客户端 |

### 7.1 工具模块启动（必须最早）

主工程 / 模块独立运行均需：

```dart
await ModuleUtilsInitializer.initialize(
  config: ModuleUtilsConfig(enableLog: kDebugMode, logTag: 'app'),
);
```

在 `MaterialApp.builder` 中：

```dart
builder: (context, child) => ModuleUtilsInitializer.wrapApp(
  builder: (_, __) => child ?? const SizedBox.shrink(),
),
```

`SpManager` 会复用 `SpUtils` 已初始化的 SharedPreferences 实例。

各业务模块 `pubspec.yaml` 添加：

```yaml
module_utils:
  path: ../../commons/toolkit
```

**模块间禁止：** 业务模块互相 import 页面/ViewModel。需要通信时使用：

- 路由跳转（`Get.toNamed(RoutePath.xxx)`）
- 抽象接口（如 `AppConfigController`）+ GetX 注册
- EventBus（`module_utils`，按需）

---

## 8. 新建业务模块 checklist

1. 创建 `module_xxx/` 目录与 `pubspec.yaml`（依赖 `module_route`、`get`，按需 `module_http`、`module_common_ui`）
2. 按 **§2** 建立 `view / viewmodel / repository / api / model` 目录
3. 实现 `xxx_module.dart`（`FeatureModule`）
4. 在 `module_route/route/route_path.dart` 添加路由常量
5. 在 `lib/config/module_manifest.dart` 注册
6. 在根 `pubspec.yaml` 添加 path 依赖
7. 添加 `lib/main_dev.dart` 支持独立运行
8. 运行 `flutter pub get && flutter analyze`

---

## 9. 当前已注册模块

| moduleId | 包名 | Tab | 主要路由 | 成熟度 | 独立运行 |
|----------|------|-----|----------|--------|----------|
| home | module_home | ✅ (0) | `/home`, `/home/all_services`, `/home/used_car` | 高 | ✅ |
| chat | module_chat | ✅ (1) | `/chat`, `/chat/detail` | 高 | ✅ |
| community | module_community | ✅ (2) | `/community`, `/community/publish` | 中 | ✅ |
| settings | module_settings | ✅ (3) | `/mine`, `/settings`, `/settings/*_debug` | 高 | ✅ |
| auth | module_auth | — | `/login`, `/register` | 高 | — |
| video | module_video | — | `/video/short`, `/video/dubbing/*` | 中 | — |
| classroom | module_classroom | — | `/classroom/*` | 中 | — |
| music | module_music | — | `/music/list`, `/music/now_playing` | 中 | — |
| live | module_live | — | `/live`, `/live/room` | 低 | — |
| pay | module_pay | — | `/pay`, `/pay/membership` | 低 | — |
| friend | module_friend | — | `/friend` | 低 | — |
| bfui | module_bfui | — | `/bfui/*` | Demo | — |

基础设施模块（不参与 manifest）：`commons/*`、`packages/route`、`packages/infrastructure/*`

完整模块职责与依赖关系见 [architecture.md §4](./architecture.md#4-features--业务模块层)。

---

## 10. 常用命令

```bash
# 主 App 运行
flutter pub get
flutter run

# 国际化生成
flutter gen-l10n

# 模块独立运行
flutter run -t features/home/lib/main_dev.dart

# 分析核心代码
flutter analyze lib/ features/home/ features/settings/ packages/route/
```

---

## 11. 禁用模块示例

禁用 **community** 模块：

**Step 1** — `lib/config/module_manifest.dart`：

```dart
// import 'package:module_community/community_module.dart';

List<FeatureModule> buildEnabledModules() {
  return [
    HomeModule(),
    ChatModule(),
    // CommunityModule(),
    SettingsModule(),
    ...
  ];
}
```

**Step 2（可选）** — `pubspec.yaml`：

```yaml
# module_community:
#   path: ./module_community
```

重新 `flutter pub get` 后，主 App Tab 少一项，路由表不再包含 `/community`，项目正常编译运行。

---

## 12. MVVM 数据流示意

```
用户点击刷新
    ↓
HomePage (View)  →  controller.refreshBanners()
    ↓
HomeViewModel    →  runAsync { banners = await repository.loadBanners() }
    ↓
HomeRepository   →  api.fetchBanners()
    ↓
HomeApi          →  HttpManager.get('banner/json')
    ↓
Obx 重建 UI
```

---

## 13. 参考文件索引

| 文件 | 说明 |
|------|------|
| [docs/architecture.md](./architecture.md) | 三层架构总览（lib / commons / features） |
| [AGENTS.md](../AGENTS.md) | HTTP/Auth/Realtime/GetX 开发规范 |
| `lib/config/module_manifest.dart` | 模块启用清单 |
| `packages/route/lib/module/feature_module.dart` | 模块契约 |
| `packages/route/lib/module/module_registry.dart` | 注册中心 |
| `commons/ui/lib/base/base_viewmodel.dart` | ViewModel 基类 |
| `features/home/lib/home_module.dart` | 标准模块实现范例 |
| `features/settings/lib/mine/viewmodel/mine_http_test_viewmodel.dart` | 网络页 ViewModel 范例 |
| `lib/pages/main_page.dart` | 动态 Tab 容器 |
| `lib/main.dart` | 启动与模块 bootstrap |

---

如有新模块或架构变更，请同步更新本文档、[architecture.md](./architecture.md) 与 `module_manifest.dart`。
