import 'package:flutter/foundation.dart';
import 'package:module_http/module_http.dart';

class HomeHttpConfig {
  static const String baseUrl = 'https://www.wanandroid.com/';

  static void ensureInitialized({
    bool enableLog = kDebugMode,
    int maxRetries = 3,
  }) {
    if (HttpManager.instance.isInitialized) return;
    HttpManager.instance.init(
      HttpClientConfig(
        baseUrl: baseUrl,
        responseParser: const _HomeResponseParser(),
        enableLog: enableLog,
        maxRetries: maxRetries,
      ),
    );
  }
}

class _HomeResponseParser implements HttpResponseParser {
  const _HomeResponseParser();

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
    if (errorCode != 0) {
      throw HttpRequestException(
        message: rawData['errorMsg']?.toString() ?? '请求失败',
        code: errorCode?.toString(),
        statusCode: response.statusCode,
        data: rawData,
        origin: response,
      );
    }

    return HttpResult<T>.success(
      data: _convert(rawData['data'], converter),
      code: errorCode is int ? errorCode : int.tryParse('$errorCode'),
      message: rawData['errorMsg']?.toString(),
      rawData: rawData,
      response: response,
    );
  }

  T? _convert<T>(dynamic rawData, JsonConverter<T>? converter) {
    if (converter != null) return converter(rawData);
    if (rawData == null) return null;
    if (rawData is T) return rawData;
    return rawData as T;
  }
}
