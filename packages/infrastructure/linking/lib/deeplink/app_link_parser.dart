import 'package:module_core/web/web_page_config.dart';
import 'package:module_linking/config/linking_config.dart';
import 'package:module_linking/deeplink/deeplink_route_table.dart';
import 'package:module_linking/models/app_route_intent.dart';
import 'package:module_route/route/route_path.dart';

/// HTTPS / Custom Scheme 统一解析。
class AppLinkParser {
  const AppLinkParser();

  AppRouteIntent? parse(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    return parseUri(uri);
  }

  AppRouteIntent parseUri(Uri uri) {
    final normalized = _normalize(uri);
    final path = normalized.path;

    if (path.startsWith(LinkingConfig.appPathPrefix)) {
      final intent = DeeplinkRouteTable.resolve(normalized);
      if (intent != null) {
        return intent.copyWith(
          source: LinkSource.deeplink,
          originalUrl: normalized.toString(),
        );
      }
    }

    return AppRouteIntent(
      route: RoutePath.web,
      arguments: WebPageConfig.url(
        url: normalized.toString(),
        title: '详情',
      ),
      source: LinkSource.deeplink,
      originalUrl: normalized.toString(),
    );
  }

  Uri _normalize(Uri uri) {
    if (uri.scheme == LinkingConfig.customScheme) {
      final host = uri.host;
      final path = uri.path;
      String fullPath;
      if (host == 'app') {
        fullPath = '${LinkingConfig.appPathPrefix}$path';
      } else if (host.isEmpty) {
        fullPath = path.startsWith(LinkingConfig.appPathPrefix)
            ? path
            : '${LinkingConfig.appPathPrefix}$path';
      } else {
        fullPath = '${LinkingConfig.appPathPrefix}/$host$path';
      }
      return Uri(
        scheme: 'https',
        host: LinkingConfig.productionHost,
        path: fullPath,
        queryParameters: uri.queryParameters,
      );
    }

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return uri;
    }

    return uri;
  }
}
