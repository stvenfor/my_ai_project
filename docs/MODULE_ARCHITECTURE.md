# Flutter 模块化 + MVVM 架构使用文档

本文档说明 `flutter_module_sample` 的项目结构、模块配置方式、MVVM 分层规范、独立运行方法，以及如何安全地启用/禁用模块。

---

## 1. 总体架构

```
module_sample（主工程壳）
├── lib/                         # 启动、manifest、Splash/Main
├── packages/
│   ├── core/                    # 契约 + 跨模块模型
│   ├── route/                   # 路由基础设施 + FeatureModule
│   ├── network/                 # Dio + AppHttpBootstrap
│   ├── storage/                 # sqflite、AppSettings
│   ├── toolkit/                 # 第三方工具封装（唯一安装点）
│   ├── ui/                      # 主题、Loading/Refresh、BaseViewModel
│   └── features/                # 业务模块（禁止互依赖）
│       ├── home / settings / auth / chat / …
```

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
  → AppInitializer.init()
      → SpManager / AppDatabase 初始化
      → ModuleRegistry.registerAll(buildEnabledModules())
      → ModuleRegistry.bootstrap()        // 各模块 onRegister
      → RepositoryApi.initHttp()          // 全局 HTTP（可选）
      → AppBinding + 各模块 Binding
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
flutter run -t module_home/lib/main_dev.dart
```

独立运行时：

- `ModuleHostContext.standalone()` 传入 `onRegister`
- 模块自行初始化 HTTP（如 `HomeHttpConfig.ensureInitialized()`）
- `ModuleStandaloneRunner.run(XxxModule())` 启动最小 GetMaterialApp

已提供 `main_dev.dart` 的模块：

| 模块 | 入口文件 |
|------|----------|
| module_home | `module_home/lib/main_dev.dart` |
| module_chat | `module_chat/lib/main_dev.dart` |
| module_community | `module_community/lib/main_dev.dart` |
| module_settings | `module_settings/lib/main_dev.dart` |

---

## 5. 网络请求规范

### 5.1 模块内自包含

请求逻辑放在模块的 `api/` 层，**不要**从主工程或 `module_repository` 直接调用业务接口。

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
cd module_global_cache
dart run build_runner build
```

---

## 7. 跨模块共享能力

| 模块 | 用途 |
|------|------|
| `module_utils`（packages/commons/toolkit） | **工具统一入口**：Log/SP/CacheImage/Svg/Lottie/Html/ScreenUtil |
| `module_common_ui`（packages/commons/ui） | 主题、UiKit、BaseViewModel |
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
  path: ../module_utils
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

| moduleId | 包名 | Tab | 路由 | MVVM | 独立运行 |
|----------|------|-----|------|------|----------|
| home | module_home | ✅ | `/home` | ✅ | ✅ |
| chat | module_chat | ✅ | `/chat` | ✅ | ✅ |
| community | module_community | ✅ | `/community` | ✅ | ✅ |
| settings | module_settings | ✅（Mine） | `/mine`, `/settings`, `/mine/http_test` | ✅ | ✅ |
| auth | module_auth | — | `/login`, `/register` | 占位 | — |
| friend | module_friend | — | `/friend` | 占位 | — |
| live | module_live | — | `/live` | 占位 | — |
| pay | module_pay | — | `/pay` | 占位 | — |
| video | module_video | — | `/video` | 占位 | — |

基础设施模块（不参与 manifest）：`packages/commons/network`、`packages/route`、`packages/commons/ui`、`packages/commons/storage`、`packages/commons/toolkit`

---

## 10. 常用命令

```bash
# 主 App 运行
flutter pub get
flutter run

# 国际化生成
flutter gen-l10n

# 模块独立运行
flutter run -t module_home/lib/main_dev.dart

# 分析核心代码
flutter analyze lib/ module_home/ module_settings/ module_route/
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
| `lib/config/module_manifest.dart` | 模块启用清单 |
| `module_route/lib/module/feature_module.dart` | 模块契约 |
| `module_route/lib/module/module_registry.dart` | 注册中心 |
| `module_common_ui/lib/base/base_viewmodel.dart` | ViewModel 基类 |
| `module_home/lib/home_module.dart` | 标准模块实现范例 |
| `module_settings/lib/mine/viewmodel/mine_http_test_viewmodel.dart` | 网络页 ViewModel 范例 |
| `lib/pages/main_page.dart` | 动态 Tab 容器 |
| `lib/main.dart` | 启动与模块 bootstrap |

---

如有新模块或架构变更，请同步更新本文档与 `module_manifest.dart`。
