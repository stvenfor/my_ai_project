import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/route_path.dart';

/// 打开统一 WebView 页的便捷入口（内部即 [RoutePath.web] 命名路由）。
///
/// 推荐业务直接使用：
/// `Get.toNamed(RoutePath.web, arguments: WebPageConfig.xxx(...))`
@Deprecated('请直接使用 Get.toNamed(RoutePath.web, arguments: WebPageConfig...)')
class WebNavigator {
  WebNavigator._();

  /// 打开 Web 容器页，支持返回 H5 通过 [closeWithResult] 传回的结果。
  static Future<T?> open<T>(WebPageConfig config) async {
    return Get.toNamed<T>(RoutePath.web, arguments: config);
  }

  /// 加载本地 asset HTML。
  static Future<T?> openAsset<T>({
    required String assetPath,
    String? title,
    Map<String, dynamic>? params,
    bool showAppBar = true,
    bool showBackButton = true,
  }) {
    return open<T>(
      WebPageConfig.asset(
        assetPath: assetPath,
        title: title,
        params: params,
        showAppBar: showAppBar,
        showBackButton: showBackButton,
      ),
    );
  }

  /// 加载远程 URL。
  static Future<T?> openUrl<T>({
    required String url,
    String? title,
    Map<String, dynamic>? params,
    bool showAppBar = true,
    bool showBackButton = true,
  }) {
    return open<T>(
      WebPageConfig.url(
        url: url,
        title: title,
        params: params,
        showAppBar: showAppBar,
        showBackButton: showBackButton,
      ),
    );
  }
}
