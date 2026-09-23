# iOS / 真机启动注意事项

> **场景**：Flutter `my_ai_project` 在模拟器、USB 真机、**无线真机**上 `run` / 联调。  
> **配对后端**：Go [dual-end-lan-startup.md](../../my_code_study/my_go_study/docs/dual-end-lan-startup.md) · 真机连不上服务端见 [ios-lan-device-debug-2026-09-16.md](../../my_code_study/my_go_study/docs/ios-lan-device-debug-2026-09-16.md)。

---

## 0. 硬规则（先看这个）

| 连接方式 | 必须用的模式 | 原因 |
|----------|--------------|------|
| **无线 (wireless)** | **release** | Flutter 仅 release 不挂调试器；debug/profile 都会起本机 `lldb` + 真机 `debugserver`，易卡死、无法进后台 |
| **USB 线连** | **debug** | 需要热重载 / DevTools / DoKit；有线 debug attach 相对稳定 |
| 模拟器 | debug | 本机 loopback，无无线 LLDB 问题 |

```text
无线  →  release（验证业务、联调登录/接口）
USB   →  debug （改 UI / 热重载）
```

**不要**在无线下跑 debug 或 profile「图省事」——这是冻屏主因，已多次核实。

---

## 1. 怎么启动

### 1.1 无线 → release

```bash
cd /Users/mac/Desktop/github/my_ai_project

# 推荐：脚本检测到 (wireless) 会自动加 --release
./scripts/run_app.sh --lan -d <udid>

# 显式也可以
./scripts/run_app.sh --lan -d <udid> -r
```

IDE：Run → **「my_ai_project (LAN 真机)」**（已默认 `flutterMode: release`）。

### 1.2 USB → debug

1. 用线连接 iPhone，在 Xcode / `flutter devices` 里应看到设备名**不带** `(wireless)`  
2. 再跑：

```bash
./scripts/run_app.sh --lan -d <udid> --force-debug
# 或不要自动挡时，USB 下直接默认 debug：
./scripts/run_app.sh --lan -d <udid>
```

IDE：Run → **「my_ai_project (LAN 真机 · debug·需USB)」**。

| 场景 | CLI | IDE |
|------|-----|-----|
| 无线联调业务 | `./scripts/run_app.sh --lan -d <udid>`（自动 release） | 「LAN 真机」 |
| USB 热重载 | `./scripts/run_app.sh --lan -d <udid> --force-debug` | 「LAN 真机 · debug·需USB」 |
| 模拟器 | `./scripts/run_app.sh --ios` | 「模拟器 / 本机 .env」 |

```bash
flutter devices
# 无线示例：奥斯特懦夫斯基 (wireless) · 00008110-…  → 用 release
# USB 示例：  奥斯特懦夫斯基 · 00008110-…           → 用 debug
```

> Flutter 工具链事实：**只有 `--release`** 走 `DebuggingOptions.disabled`（纯 install + launch）。  
> **`--profile` 仍会挂 LLDB**，无线下与 debug 一样会冻，不要用 profile 当「折中」。

---

## 2. 无线 vs USB 对照

| | USB + debug | 无线 + release |
|--|-------------|----------------|
| 热重载 / DevTools | ✅ | ❌ |
| 冻屏 / 无法进后台风险 | 低（中断后仍建议走 `run_app.sh`） | 若误用 debug/profile → **很高** |
| 适用 | 改页面、查日志、断点 | 真机联调登录 / API / 验收 |
| `BACKEND_HOST` | 仍须 `.env.lan` / `--lan` | 同左 |

---

## 3. 卡死且无法推到后台

### 现象

- 页面完全不动；**Home 无效、进不了后台**；多任务有时划不掉  

### 根因

误在无线上跑了 **debug/profile**，残留：

```text
Mac:  /usr/bin/lldb
手机: /usr/libexec/debugserver  +  Runner（常被 SIGSTOP）
```

### 立刻恢复

```bash
cd /Users/mac/Desktop/github/my_ai_project
./scripts/cleanup_ios_debug.sh -d <udid>
# 仍不行：
./scripts/cleanup_ios_debug.sh -d <udid> --uninstall

# 恢复后按硬规则重跑（无线 → release）
./scripts/run_app.sh --lan -d <udid>
```

### 避免再犯

1. 无线只用 release（脚本已自动切换；勿加 `--force-debug`）  
2. 要用 debug → **先插 USB**，确认 `flutter devices` 无 `(wireless)`  
3. 启动尽量走 `./scripts/run_app.sh`（Ctrl+C 会拆 LLDB + debugserver + Runner）  
4. IDE / 裸 `flutter run` 中断后若冻 → 立刻 `cleanup_ios_debug.sh`

### App 侧兜底（解不了 debugserver 挂起）

| 位置 | 行为 |
|------|------|
| `lib/bootstrap/app_runner_*.dart` | init 超时仍进 UI，并保证 `AppController` 已注册 |
| `lib/pages/splash_page.dart` | 导航超时显示「重试进入」 |

---

## 4. 启动检查清单

```text
□ 先看 flutter devices：是 (wireless) 还是 USB？
□ 无线 → release；USB 要热重载 → debug（--force-debug 或 IDE debug 配置）
□ Go：curl 本机与 <LAN_IP>:8080/health 都 ok
□ Flutter：.env.lan 里 BACKEND_HOST=<LAN_IP>（与 Go REALTIME_PUBLIC_WS_HOST 一致）
□ 启动日志：BACKEND_HOST=不是「(未注入)」
□ 卡死无法进后台：cleanup_ios_debug.sh，再按硬规则重跑
```

---

## 5. 常见报错对照

| 报错 / 现象 | 含义 | 处理 |
|-------------|------|------|
| 卡死 + **无法进后台** | 无线误用 debug/profile，残留 debugserver | `cleanup_ios_debug.sh`；改用 **release** |
| `Error launching application on … (wireless)` | 无线 debug attach 失败 | 改 **release**，或插 USB 用 debug |
| `code -27` | 旁路设备无线不可达 | 可忽略旧机；目标机解锁 + 同 Wi‑Fi |
| 登录「无法连接服务端（`127.0.0.1`）」 | 未注入 `BACKEND_HOST` | `--lan` **完整重装** |
| `"AppController" not found` | init 超时半启动（已修） | 完整重装最新代码；仍红则 cleanup 后再 release |

---

## 6. 相关文档 / 脚本

| 路径 | 内容 |
|------|------|
| [USAGE_GUIDE.md](./USAGE_GUIDE.md) | 日常运行 |
| [BACKEND_INTEGRATION.md](./BACKEND_INTEGRATION.md) | 与 Go 对接 |
| `scripts/run_app.sh` | 启动；无线自动 release；中断清理 |
| `scripts/cleanup_ios_debug.sh` | 冻屏一键恢复 |
| Go [dual-end-lan-startup.md](../../my_code_study/my_go_study/docs/dual-end-lan-startup.md) | 两端 LAN 手册 |
