/// JS Bridge 约定常量。
class WebBridgeConstants {
  WebBridgeConstants._();

  /// [InAppWebView.addJavaScriptHandler] 注册的 channel 名。
  static const channelName = 'AppBridge';

  /// Flutter 注入参数后触发的 DOM 事件名。
  static const jsReadyEvent = 'flutterReady';

  /// H5 读取 Flutter 参数的 window 键名。
  static const jsParamsKey = '__FLUTTER_PARAMS__';
}
