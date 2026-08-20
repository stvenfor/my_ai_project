import 'wys_url_utils.dart';

/// 原生 / 旧工程 pageName → GetX path（主工程启动时注入）。
class WysNativePageNameMap {
  WysNativePageNameMap._();

  static final Map<String, String> _pageNameToPath = {};

  static void replaceAll(Map<String, String> mapping) {
    _pageNameToPath
      ..clear()
      ..addAll(mapping);
  }

  static void register(String pageName, String getPath) {
    _pageNameToPath[pageName] = getPath;
  }

  static String? pathFor(String pageName) => _pageNameToPath[pageName];

  /// 支持完整 URL / `/orderList` / 裸 `orderList`。
  static String? pathForUrlOrPageName(String urlOrPath) {
    final trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) return null;
    final direct = pathFor(trimmed);
    if (direct != null) return direct;

    final standard = WysUrlUtils.standardPath(trimmed);
    if (standard.isEmpty) return null;
    if (pathFor(standard) != null) return pathFor(standard);
    final pageName =
        standard.startsWith('/') ? standard.substring(1) : standard;
    if (pageName.isEmpty) return null;
    return pathFor(pageName);
  }
}
