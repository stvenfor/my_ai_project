import 'package:module_http/module_http.dart';
import 'package:module_repository/repository/app_http_bootstrap.dart';

class RepositoryApi {
  static const String banner = 'banner/json';
  static const String homeTopList = 'article/top/json';
  static const String knowledgeTree = 'tree/json';
  static const String hotKey = 'hotkey/json';
  static const String commonWebsite = 'friend/json';

  static String homeList(int page) => 'article/list/$page/json';

  static String knowledgeDetailList({
    required int page,
    required int cid,
  }) {
    return 'article/list/$page/json?cid=$cid';
  }

  static String search(int page) => 'article/query/$page/json';

  static void initHttp({
    HttpHeaderProvider? headerProvider,
    HttpResponseHook? responseHook,
    bool enableLog = false,
    int maxRetries = 0,
  }) {
    AppHttpBootstrap.initialize(
      headerProvider: headerProvider,
      responseHook: responseHook,
      enableLog: enableLog,
      maxRetries: maxRetries,
    );
  }

  static String get baseUrl => AppHttpBootstrap.resolveBaseUrl();
}

class WanAndroidResponseParser implements HttpResponseParser {
  const WanAndroidResponseParser();

  @override
  HttpResult<T> parse<T>(
    Response<dynamic> response, {
    JsonConverter<T>? converter,
  }) {
    final rawData = response.data;
    if (rawData is! Map<String, dynamic> || !rawData.containsKey('errorCode')) {
      return const DefaultHttpResponseParser().parse<T>(
        response,
        converter: converter,
      );
    }

    final errorCode = rawData['errorCode'];
    final errorMsg = rawData['errorMsg']?.toString();
    final data = rawData['data'];
    final success = errorCode == 0;

    if (!success) {
      throw HttpRequestException(
        message: errorMsg?.isNotEmpty == true ? errorMsg! : '业务请求失败',
        code: errorCode?.toString(),
        statusCode: response.statusCode,
        data: rawData,
        origin: response,
      );
    }

    return HttpResult<T>.success(
      data: _convertData(data, converter),
      code: errorCode is int ? errorCode : int.tryParse('$errorCode'),
      message: errorMsg,
      rawData: rawData,
      response: response,
    );
  }

  T? _convertData<T>(dynamic rawData, JsonConverter<T>? converter) {
    if (converter != null) return converter(rawData);
    if (rawData == null) return null;
    if (rawData is T) return rawData;
    return rawData as T;
  }
}
