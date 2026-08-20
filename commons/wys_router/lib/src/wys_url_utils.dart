/// URL / path 规范化（对齐 gaodun [UrlUtils.getStandardPath]）。
abstract final class WysUrlUtils {
  WysUrlUtils._();

  /// 去掉 scheme、host，得到以 `/` 开头的 path（无 query）。
  static String standardPath(String urlOrPath) {
    if (urlOrPath.isEmpty) return '';
    final trimmed = urlOrPath.trim();
    if (trimmed.startsWith('/')) {
      final q = trimmed.indexOf('?');
      return q < 0 ? trimmed : trimmed.substring(0, q);
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return '';
    var path = uri.path;
    if (path.isEmpty) return '';
    if (!path.startsWith('/')) path = '/$path';
    return path;
  }

  /// 解析 query；支持完整 URL 或 `path?a=1`。
  static Map<String, String> queryParameters(String urlOrPath) {
    if (urlOrPath.isEmpty) return {};
    final trimmed = urlOrPath.trim();
    final uri = trimmed.startsWith('/')
        ? Uri.parse('tf://local$trimmed')
        : Uri.tryParse(trimmed);
    if (uri == null) return {};
    return Map<String, String>.from(uri.queryParameters);
  }

  /// path + query 合并为 arguments（query 值均为 String，业务可自行转型）。
  static Map<String, dynamic> mergeArguments(
    String urlOrPath, {
    Map<String, dynamic>? extra,
  }) {
    final merged = <String, dynamic>{
      ...queryParameters(urlOrPath),
      if (extra != null) ...extra,
    };
    return merged;
  }
}