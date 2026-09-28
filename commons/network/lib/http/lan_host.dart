/// 局域网后端回退主机。
///
/// ⚠️ 这里**刻意留空，不要再填入任何具体 IP**。
///
/// 它曾经写死过「当前开发者本机的局域网地址」，结果 git 历史里反复互相覆盖
/// （`192.168.0.102` ↔ `172.16.0.43`），每个拉代码的人都要手改这一行才能联调。
/// 机器相关的值不属于源码。
///
/// 需要局域网后端时，走配置注入（都不入库）：
///   - `.env.lan` 的 `BACKEND_HOST`（已 gitignore，由 Go 仓 `make sync-lan-ip` 写入）
///   - `flutter run --dart-define=BACKEND_HOST=<ip>`
///   - `./scripts/run_app.sh --lan -d <device_id>`
///
/// 真机联调**必须**显式注入；模拟器与桌面端走 loopback，本来就不需要它。
class LanHost {
  LanHost._();

  static const fallback = '';

  /// 旧名兼容（避免外部引用断裂）。
  static const debugFallback = fallback;
}
