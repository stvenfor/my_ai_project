import 'package:module_http/module_http.dart';
import 'package:module_repository/repository/app_http_bootstrap.dart';

class MineHttpConfig {
  static String get baseUrl => AppHttpBootstrap.resolveBaseUrl();

  static const String harmonyIndexPath = '/harmony/index/json';

  static void init({bool enableLog = false, int maxRetries = 0}) {
    AppHttpBootstrap.initialize(
      headerProvider: const MineHeaderProvider(),
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }
}

class MineHeaderProvider implements HttpHeaderProvider {
  const MineHeaderProvider();

  @override
  Map<String, dynamic> getHeaders(RequestOptions options) {
    return const {
      Headers.acceptHeader: Headers.jsonContentType,
      Headers.contentTypeHeader: Headers.jsonContentType,
    };
  }
}
