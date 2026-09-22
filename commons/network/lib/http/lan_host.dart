/// 局域网后端回退主机（Debug / Profile / Release 共用）。
///
/// Xcode / IDE「Run」「Release」、裸 `flutter run` 可能不带
/// `--dart-define-from-file=.env.lan`。仅当 [BACKEND_HOST] 未注入、
/// 且目标是 127.0.0.1/localhost 时使用。
/// 值由 Go 仓 `make sync-lan-ip` 按当前网卡写入，与 `.env.lan` 的 `BACKEND_HOST` 对齐。
class LanHost {
  LanHost._();

  static const fallback = '172.16.0.43';

  /// 旧名兼容（避免外部引用断裂）。
  static const debugFallback = fallback;
}
