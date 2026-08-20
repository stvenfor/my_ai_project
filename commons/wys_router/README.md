# wys_router

统一路由基础设施：

- **本工程 path 真源**：[RoutePath]（Splash `/`、Main `/main`、各 feature）
- **模块契约**：`FeatureModule` / `ModuleRegistry` / `ModuleStandaloneRunner`
- **URL / 原生桥**：`WysRouter.routeURL`、Capability 路由、Android / iOS / OHOS plugin

## 依赖

```yaml
wys_router:
  path: commons/wys_router
```

## 壳工程启动

```dart
WysRouter.configure(
  WysRouteConfiguration(scheme: 'xiaomao'),
);
WysRouter.registerPath(WysCapabilityRoutes.h5, RoutePath.web);
WysRouter.registerPath(WysCapabilityRoutes.web, RoutePath.web);
```

## 页面跳转

```dart
import 'package:wys_router/wys_router.dart';

Get.toNamed(RoutePath.home);
// 或 URL / 原生 pageName：
WysRouter.routeURL('/home');
WysRouter.offAllNamed(RoutePath.splash);
```

## Feature 注册

各模块实现 `FeatureModule`，由主工程 `module_manifest.dart` 注入 `ModuleRegistry`。
路径常量只写在 `RoutePath`，禁止 feature 内硬编码字符串。
