import '../network_codes.dart';

/// 与 iOS `TFStatusInfo`、接口 JSON `{ code, message, data }` 一致。
class ApiResponse<T> {
  const ApiResponse({
    required this.code,
    this.message,
    this.data,
    this.raw,
  });

  final int code;
  final String? message;
  final T? data;

  /// 原始 body（`code == -1` 透传等场景）
  final dynamic raw;

  bool get isSuccess => code == NetworkCodes.ok;

  factory ApiResponse.fromJson(
    dynamic json, {
    T Function(dynamic data)? dataParser,
  }) {
    if (json is! Map) {
      return ApiResponse(
        code: NetworkCodes.notNetwork,
        message: '响应格式错误',
        raw: json,
      );
    }
    final map = Map<String, dynamic>.from(json);
    final code = _asInt(map['code']);
    final message = map['message']?.toString();
    final dataRaw = map['data'];
    T? parsed;
    if (dataParser != null) {
      parsed = dataParser(dataRaw);
    } else {
      parsed = dataRaw as T?;
    }
    return ApiResponse(
      code: code,
      message: message,
      data: parsed,
      raw: json,
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? NetworkCodes.notNetwork;
    return NetworkCodes.notNetwork;
  }
}