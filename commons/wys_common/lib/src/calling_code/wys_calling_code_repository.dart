import 'package:dio/dio.dart';

import 'wys_calling_code_item.dart';

/// 国家区号 CDN 拉取，对齐安卓 `UserService.getCallingCodes` /
/// 登录模块 `LoginRepository.getCallingCodes`。
class WysCallingCodeRepository {
  WysCallingCodeRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// 生产 CDN（非 `{code,data,message}` 业务包装）。
  static const defaultUrl =
      'https://cos.tfent.cn/xgg-file-folder/tf-app/resource/countrycode.json';

  Future<List<WysCallingCodeItem>> fetchCallingCodes({
    String url = defaultUrl,
  }) async {
    final response = await _dio.get<dynamic>(url);
    return parseCallingCodes(response.data);
  }

  /// 解析 CDN JSON：`{ code, names, codePlus? }`。
  static List<WysCallingCodeItem> parseCallingCodes(dynamic body) {
    if (body is! Map) return const [];
    final names = body['names'];
    if (names is! List) return const [];

    final codePlus = body['codePlus'];
    final codes = body['code'];
    final result = <WysCallingCodeItem>[];

    for (var i = 0; i < names.length; i++) {
      final name = names[i]?.toString() ?? '';
      if (name.isEmpty) continue;

      String raw;
      if (codePlus is List && i < codePlus.length) {
        raw = codePlus[i]?.toString() ?? '';
      } else if (codes is List && i < codes.length) {
        raw = codes[i]?.toString() ?? '';
      } else {
        continue;
      }
      if (raw.isEmpty) continue;

      result.add(
        WysCallingCodeItem(
          name: name,
          code: raw.startsWith('+') ? raw : '+$raw',
        ),
      );
    }
    return result;
  }
}
