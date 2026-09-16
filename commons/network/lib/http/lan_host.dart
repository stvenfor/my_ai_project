/// Debug/profile LAN 回退主机。
///
/// Xcode / 裸 `flutter run` 不会带 `--dart-define-from-file=.env.lan`。
/// 仅当 [BACKEND_HOST] 未注入、且目标是 127.0.0.1/localhost 时使用。
/// 请与 `.env.lan` 的 `BACKEND_HOST`、Go `REALTIME_PUBLIC_WS_HOST` 保持一致。
class LanHost {
  LanHost._();

  static const debugFallback = '172.16.0.43';
}
