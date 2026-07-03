# packages/commons — 公共基础能力

本目录聚合项目内可复用的基础 package，供 `features/` 与 `infrastructure/` 按需依赖。

| 目录 | package name | 职责 |
|------|-------------|------|
| `core/` | `module_core` | 共享模型、服务契约、环境配置、Web Bridge 协议 |
| `ui/` | `module_common_ui` | 主题、布局、对话框、WebView、BaseViewModel |
| `toolkit/` | `module_utils` | Log/SP/EventBus/ScreenUtil、短视频播放器等工具 |
| `network/` | `module_http` | HTTP 封装与统一初始化 |
| `storage/` | `module_global_cache` | SharedPreferences、SQLite 缓存 |

## 依赖约定

- commons 内部：`ui` 依赖 `core`、`toolkit`；`network` 依赖 `core`；`storage` 依赖 `toolkit`
- 业务模块通过 `path: ../../commons/<name>` 引用，**禁止** feature 之间直接互引页面/ViewModel
- 路由与模块注册框架见同级目录 [`../route/`](../route/)
