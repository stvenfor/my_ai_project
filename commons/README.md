# commons — 公共基础能力

本目录与根目录 `lib/`、`features/`、`components/` **同级**，聚合项目内可复用的基础 package。

## module_*（本工程主栈）

| 目录 | package name | 职责 |
|------|-------------|------|
| `core/` | `module_core` | 共享模型、服务契约、环境配置、Web Bridge 协议 |
| `ui/` | `module_common_ui` | 主题、布局、对话框、WebView、BaseViewModel |
| `toolkit/` | `module_utils` | Log/SP/EventBus/ScreenUtil、短视频播放器等工具 |
| `network/` | `module_http` | HTTP 封装与统一初始化 |
| `storage/` | `module_global_cache` | SharedPreferences、SQLite 缓存 |

**module_* 内部分层**：`ui` 依赖 `core`、`toolkit`、`wys_router`；`network` 依赖 `core`；`storage` 依赖 `toolkit`。

## wys_*（含已合并的路由栈）

| 目录 | package name | 职责 | 与主栈关系 |
|------|-------------|------|------------|
| `wys_router/` | `wys_router` | `RoutePath` / `FeatureModule` / `ModuleRegistry` + URL/原生桥 | **路由唯一包**（原 `module_route` 已并入） |
| `wys_network/` | `wys_network` | Dio/`HttpsClient`、环境与拦截器 | 并存于 `module_http`；新业务优先 `module_http` |
| `wys_account/` | `wys_account` | **DEPRECATED** 登录态门面（勿初始化） | Session Owner 为 `module_auth`（ADR 0006 / 0009）；包保留未删 |
| `wys_common/` | `wys_common` | Toast/扫码/WebView/预览等杂项 | 并存于 `module_common_ui` / `module_utils` |

**未迁入**：`fluttertoast`、`audioplayers_ohos` 包目录（按约定排除；`wys_common` 仍可 git 依赖 CPF `fluttertoast`）。

## 依赖约定

- 业务模块通过 `path: ../../commons/<name>` 引用，**禁止** feature 之间直接互引页面/ViewModel
- 横切能力见 [`../components/`](../components/)
- `wys_*` 包勿反向依赖 `features/`；`wys_network` / `wys_common` 逐步收敛时优先合入 `module_*`；`wys_account` 已废弃，新代码用 `module_auth`
