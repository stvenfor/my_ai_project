/// 内置能力路由 path（对齐 iOS `to/web`、`to/flutter` 等）。
abstract final class WysCapabilityRoutes {
  WysCapabilityRoutes._();

  static const redirect = '/to/redirect';
  static const web = '/to/web';
  static const h5 = '/to/h5';
  static const flutter = '/to/flutter';
  static const systemWeb = '/to/system-web';
}
