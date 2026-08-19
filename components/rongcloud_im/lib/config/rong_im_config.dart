/// 融云 IM 配置。
class RongImConfig {
  RongImConfig._();

  /// 控制台未就绪时使用 Mock Engine + Mock Session API。
  /// Mock 阶段不引入 rongcloud_im_wrapper_plugin，避免 iOS 加载原生 SDK 崩溃。
  static const useMockIm = true;

  static const sessionPath = '/im/session';
  static const profilePath = '/im/users/profile';
  static const backupPath = '/im/messages/backup';

  static const connectTimeoutSeconds = 15;
  static const profileCacheTtl = Duration(hours: 24);
}
