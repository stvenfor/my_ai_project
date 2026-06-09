import 'package:module_http/module_http.dart';

class MineHttpConfig {
  static const String baseUrl = 'https://www.wanandroid.com';
  static const String harmonyIndexPath = '/harmony/index/json';

  static void init({bool enableLog = false}) {
    HttpManager.instance.init(
      HttpClientConfig(
        baseUrl: baseUrl,
        headerProvider: const MineHeaderProvider(),
        responseParser: const MineResponseParser(),
        enableLog: enableLog,
      ),
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

class MineResponseParser implements HttpResponseParser {
  const MineResponseParser();

  @override
  HttpResult<T> parse<T>(
    Response<dynamic> response, {
    JsonConverter<T>? converter,
  }) {
    final rawData = response.data;
    if (rawData is! Map<String, dynamic> ||
        !rawData.containsKey('errorCode')) {
      return const DefaultHttpResponseParser().parse<T>(
        response,
        converter: converter,
      );
    }

    final errorCode = rawData['errorCode'];
    final errorMsg = rawData['errorMsg']?.toString();
    final data = rawData['data'];

    if (errorCode != 0) {
      throw HttpRequestException(
        message: errorMsg?.isNotEmpty == true ? errorMsg! : '请求失败',
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
