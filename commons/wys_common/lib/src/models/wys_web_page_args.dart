/// H5 / WebView 页面加载模式。
enum WysWebLoadMode {
  /// 远程 URL 使用 [WebViewController.loadRequest]；本地 asset 使用 [loadFlutterAsset]。
  auto,

  /// 兼容旧 PageWeb：先拉取 HTML 字符串再 [loadHtmlString]。
  htmlString,

  /// 直接加载调用方传入的 [WysWebPageArgs.htmlContent]。
  directHtml,
}

/// 通用 H5 页面参数，可从 GetX arguments / 原生桥接参数解析。
class WysWebPageArgs {
  const WysWebPageArgs({
    this.url = '',
    this.title,
    this.showAppBar = true,
    this.showBackButton = true,
    this.isAssets = false,
    this.loadMode = WysWebLoadMode.auto,
    this.enableJs = false,
    this.baseUrl,
    this.headers,
    this.htmlContent,
    this.adaptiveHeight = false,
    this.allowInteraction = true,
    this.initialHeight = 300,
  });

  /// 必填：http(s) URL 或 asset 路径。
  final String url;

  /// 导航栏标题。
  final String? title;

  /// 是否显示顶部导航栏。
  final bool showAppBar;

  /// 导航栏是否显示返回按钮。
  final bool showBackButton;

  /// `true` 时 [url] 视为 Flutter asset 路径。
  final bool isAssets;

  final WysWebLoadMode loadMode;

  final bool enableJs;

  /// [WysWebLoadMode.htmlString] 时传给 [loadHtmlString] 的 baseUrl。
  final String? baseUrl;

  /// 远程请求自定义 Header（htmlString 模式 Dio / auto 模式 loadRequest）。
  final Map<String, String>? headers;

  final String? htmlContent;
  final bool adaptiveHeight;
  final bool allowInteraction;
  final double initialHeight;

  factory WysWebPageArgs.fromMap(Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};
    return WysWebPageArgs(
      url: '${data['url'] ?? ''}',
      title: data['title']?.toString(),
      showAppBar: _readBool(data['showAppBar'], defaultValue: true),
      showBackButton: _readBool(data['showBackButton'], defaultValue: true),
      isAssets: _readBool(data['isAssets']),
      loadMode: _parseLoadMode(data['loadMode']),
      enableJs: _readBool(data['enableJs']),
      baseUrl: data['baseUrl']?.toString(),
      headers: _parseHeaders(data['headers']),
      htmlContent: data['htmlContent']?.toString(),
      adaptiveHeight: _readBool(data['adaptiveHeight']),
      allowInteraction: _readBool(data['allowInteraction'], defaultValue: true),
      initialHeight: _readDouble(data['initialHeight'], defaultValue: 300),
    );
  }

  static WysWebLoadMode _parseLoadMode(Object? value) {
    if (value is WysWebLoadMode) return value;
    final raw = value?.toString();
    if (raw == 'htmlString' || raw == WysWebLoadMode.htmlString.name) {
      return WysWebLoadMode.htmlString;
    }
    if (raw == 'directHtml' || raw == WysWebLoadMode.directHtml.name) {
      return WysWebLoadMode.directHtml;
    }
    return WysWebLoadMode.auto;
  }

  static double _readDouble(Object? value, {required double defaultValue}) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    return parsed != null && parsed > 0 ? parsed : defaultValue;
  }

  static bool _readBool(Object? value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    final raw = value.toString().toLowerCase();
    if (raw == 'true' || raw == '1') return true;
    if (raw == 'false' || raw == '0') return false;
    return defaultValue;
  }

  static Map<String, String>? _parseHeaders(Object? value) {
    if (value == null) return null;
    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(key.toString(), item.toString()),
      );
    }
    return null;
  }
}
