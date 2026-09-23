import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:module_http/module_http.dart';
import 'package:module_linking/analytics/linking_analytics.dart';
import 'package:module_utils/module_utils.dart';

/// RegistrationId / Alias 上报到 Go BFF：`POST /api/v1/push/devices`。
class PushRegistrationApi {
  PushRegistrationApi({required LinkingAnalytics analytics})
      : _analytics = analytics;

  static const path = '/api/v1/push/devices';

  final LinkingAnalytics _analytics;

  Future<void> report({
    required String registrationId,
    String? alias,
    String? deviceId,
    String? platform,
    bool mock = false,
  }) async {
    LogUtils.i(
      '[PushRegistrationApi] mock=$mock registrationId=$registrationId '
      'alias=$alias platform=$platform',
    );
    _analytics.trackPushRegister(
      registrationId: registrationId,
      alias: alias,
      mock: mock,
    );

    if (mock || registrationId.isEmpty) return;

    try {
      await HttpManager.instance.post<Map<String, dynamic>>(
        path,
        data: <String, dynamic>{
          'registration_id': registrationId,
          if (alias != null && alias.isNotEmpty) 'alias': alias,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
          'platform': platform ?? _detectPlatform(),
          'mock': false,
        },
        converter: (json) =>
            json is Map<String, dynamic> ? json : <String, dynamic>{},
      );
    } catch (e) {
      LogUtils.w('[PushRegistrationApi] report failed: $e');
    }
  }

  static String _detectPlatform() {
    if (kIsWeb) return 'unknown';
    final os = Platform.operatingSystem;
    if (os == 'ohos') return 'harmony';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}
