/// WebView 页面加载方式。
enum WebPageLoadType {
  /// 本地 assets，如 assets/web/demo.html
  asset,

  /// 远程 https/http URL
  url,
}

/// 打开 WebView 时的配置。
class WebPageConfig {
  const WebPageConfig._({
    required this.loadType,
    this.assetPath,
    this.url,
    this.title,
    this.params = const {},
    this.enableJavaScript = true,
    this.showAppBar = true,
    this.showBackButton = true,
  });

  /// 加载本地 asset 文件（路径相对 Flutter 工程 assets 声明）。
  factory WebPageConfig.asset({
    required String assetPath,
    String? title,
    Map<String, dynamic>? params,
    bool enableJavaScript = true,
    bool showAppBar = true,
    bool showBackButton = true,
  }) {
    return WebPageConfig._(
      loadType: WebPageLoadType.asset,
      assetPath: assetPath,
      title: title,
      params: params ?? const {},
      enableJavaScript: enableJavaScript,
      showAppBar: showAppBar,
      showBackButton: showBackButton,
    );
  }

  /// 加载远程 URL。
  factory WebPageConfig.url({
    required String url,
    String? title,
    Map<String, dynamic>? params,
    bool enableJavaScript = true,
    bool showAppBar = true,
    bool showBackButton = true,
  }) {
    return WebPageConfig._(
      loadType: WebPageLoadType.url,
      url: url,
      title: title,
      params: params ?? const {},
      enableJavaScript: enableJavaScript,
      showAppBar: showAppBar,
      showBackButton: showBackButton,
    );
  }

  final WebPageLoadType loadType;
  final String? assetPath;
  final String? url;
  final String? title;
  final Map<String, dynamic> params;
  final bool enableJavaScript;

  /// 是否显示 Flutter 导航栏；false 时 H5 全屏（H5 可自带顶栏）。
  final bool showAppBar;

  /// 是否显示返回按钮（仅 [showAppBar] 为 true 时生效）。
  final bool showBackButton;

  String get displayTitle => title ?? '网页';
}

/// 内置测试页 asset 路径（壳工程 pubspec 声明）。
class WebBridgeAssets {
  WebBridgeAssets._();

  static const testBridge = 'assets/web/test_bridge.html';
}
