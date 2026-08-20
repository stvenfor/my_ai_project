import 'dart:io';

import 'package:flutter/foundation.dart';

/// 与 `tf-fangroup-flutter` DioConfig / HttpUtil 及 iOS 默认头一致。
class WysNetworkConfig {
  WysNetworkConfig._();

  static Duration connectTimeout = const Duration(seconds: 60);
  static Duration receiveTimeout = const Duration(seconds: 60);
  static Duration sendTimeout = const Duration(seconds: 60);

  static const String sysCode = 'tf';

  /// 混编时由原生注入（对齐 `ApiService.apiGetUserToken`）
  static String baseUrl = '';
  static String accessToken = '';

  static String? clientVersion;
  static String? clientBuildNumber;

  static bool isStar = false;
  static String subjectId = '';

  static String get clientType {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Flutter';
  }

  static bool skipAuthForUrl(String url) => url.contains('cos.tfent.cn');

  static void applyNativeSession({
    required String url,
    required String token,
    bool? star,
    String? subject,
    String? version,
    String? buildNumber,
  }) {
    baseUrl = url;
    accessToken = token;
    if (star != null) isStar = star;
    if (subject != null) subjectId = subject;
    if (version != null) clientVersion = version;
    if (buildNumber != null) clientBuildNumber = buildNumber;
  }
}