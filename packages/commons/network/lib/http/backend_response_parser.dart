import 'package:dio/dio.dart';
import 'package:module_http/api/result_model.dart';
import 'package:module_http/http/http.dart';

/// my_go_study 响应解析：返回完整 [ResultModel]，converter 解析整包 JSON。
class BackendResponseParser implements HttpResponseParser {
  const BackendResponseParser();

  @override
  HttpResult<T> parse<T>(
    Response<dynamic> response, {
    JsonConverter<T>? converter,
  }) {
    final rawData = response.data;

    if (rawData is Map<String, dynamic>) {
      final error = rawData['error'];
      if (error is String && error.isNotEmpty) {
        throw HttpRequestException(
          message: error,
          statusCode: response.statusCode,
          data: rawData,
          origin: response,
        );
      }

      if (rawData.containsKey('code')) {
        return _parseEnvelope<T>(response, rawData, converter);
      }
    }

    return const DefaultHttpResponseParser().parse<T>(
      response,
      converter: converter,
    );
  }

  HttpResult<T> _parseEnvelope<T>(
    Response<dynamic> response,
    Map<String, dynamic> envelope,
    JsonConverter<T>? converter,
  ) {
    final code = envelope['code'];
    final message = envelope['message']?.toString() ?? '';
    final success = code == 0 || code == '0';

    if (!success) {
      throw HttpRequestException(
        message: message.isNotEmpty ? message : '业务请求失败',
        code: code?.toString(),
        statusCode: response.statusCode,
        data: envelope,
        origin: response,
      );
    }

    final result = converter != null
        ? converter(envelope)
        : ResultModel<dynamic>.fromJson(envelope, (data) => data) as T;

    if (result is ResultModel) {
      final model = result;
      return HttpResult<T>.success(
        data: result,
        code: model.code,
        message: model.message,
        rawData: envelope,
        response: response,
      );
    }

    return HttpResult<T>.success(
      data: result,
      code: (code as num?)?.toInt(),
      message: message,
      rawData: envelope,
      response: response,
    );
  }
}

/// 解析 HTTP 响应为 [ResultModel]，[dataFromJson] 负责解析 `data` 字段。
ResultModel<T> expectBackendResult<T>(
  Response<dynamic> response,
  T Function(dynamic json) dataFromJson,
) {
  final raw = response.data;
  if (raw is! Map<String, dynamic>) {
    throw HttpRequestException(
      message: '后端返回空响应或格式错误',
      statusCode: response.statusCode,
    );
  }

  if (raw.containsKey('code')) {
    final code = raw['code'];
    if (code != 0 && code != '0') {
      final message = raw['message']?.toString();
      throw HttpRequestException(
        message: message?.isNotEmpty == true ? message! : '业务请求失败',
        statusCode: response.statusCode,
        data: raw,
        origin: response,
      );
    }
    return ResultModel.fromJson(raw, dataFromJson);
  }

  final error = raw['error'];
  if (error is String && error.isNotEmpty) {
    throw HttpRequestException(
      message: error,
      statusCode: response.statusCode,
      data: raw,
      origin: response,
    );
  }

  throw HttpRequestException(
    message: '后端响应缺少 code 字段',
    statusCode: response.statusCode,
    data: raw,
  );
}
