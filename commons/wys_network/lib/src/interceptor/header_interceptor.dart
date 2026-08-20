import 'package:dio/dio.dart';

import '../native_auth_provider.dart';
import '../wys_network_config.dart';

typedef HeaderProvider = Map<String, String> Function();

/// 额外头（如 `wys_account` 的 token）；与默认头合并。
HeaderProvider? globalHeaderProvider;

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
  try {
    if (nativeAuthProvider != null) {
      final session = await nativeAuthProvider!();
      WysNetworkConfig.baseUrl = session.url;
      WysNetworkConfig.accessToken = session.token;
      WysNetworkConfig.isStar = session.isStar;
      WysNetworkConfig.subjectId = session.subjectId;
      if (session.clientVersion != null) {
        WysNetworkConfig.clientVersion = session.clientVersion;
      }
      if (session.clientBuildNumber != null) {
        WysNetworkConfig.clientBuildNumber = session.clientBuildNumber;
      }
    }

    final uri = options.uri.toString();
    options.headers.putIfAbsent('Client-Type', () => WysNetworkConfig.clientType);
    options.headers.putIfAbsent('sysCode', () => WysNetworkConfig.sysCode);

    if (WysNetworkConfig.clientVersion != null) {
      options.headers['Client-Version'] = WysNetworkConfig.clientVersion;
    }
    if (WysNetworkConfig.clientBuildNumber != null) {
      options.headers['Client-BuildNumber'] = WysNetworkConfig.clientBuildNumber;
    }

    options.headers.putIfAbsent(
      'isStar',
      () => WysNetworkConfig.isStar ? '1' : '0',
    );
    if (WysNetworkConfig.isStar && WysNetworkConfig.subjectId.isNotEmpty) {
      options.headers.putIfAbsent('subjectId', () => WysNetworkConfig.subjectId);
    } else if (!options.headers.containsKey('subjectId')) {
      options.headers['subjectId'] = '';
    }

    final extra = globalHeaderProvider?.call();
    if (extra != null) {
      options.headers.addAll(extra);
    }

    if (!WysNetworkConfig.skipAuthForUrl(uri)) {
      final hasAuth = options.headers.containsKey('Authorization') &&
          options.headers['Authorization']?.toString().isNotEmpty == true;
      if (!hasAuth && WysNetworkConfig.accessToken.isNotEmpty) {
        options.headers['Authorization'] =
            'Bearer ${WysNetworkConfig.accessToken}';
      }
    }

    handler.next(options);
  } catch (e, s) {
    handler.reject(
      DioException(
        requestOptions: options,
        error: e,
        stackTrace: s,
        type: DioExceptionType.unknown,
      ),
    );
  }
  }
}