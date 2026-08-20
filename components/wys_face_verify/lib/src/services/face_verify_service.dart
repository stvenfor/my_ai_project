import 'package:flutter/services.dart';
import 'package:wys_network/wys_network.dart';

import '../models/face_verify_input.dart';
import '../models/face_verify_result.dart';

/// 腾讯云慧眼人脸核身统一入口。
///
/// 本服务只负责启动平台 SDK，不负责请求各业务的人脸参数或提交业务结果。
class WysFaceVerifyService {
  WysFaceVerifyService._();

  static final WysFaceVerifyService instance = WysFaceVerifyService._();

  static const MethodChannel _channel = MethodChannel(
    'com.tf.flutter/cloud_face_verify',
  );

  static const _productionAppId = 'IDAHV2wM';
  static const _testAppId = 'TIDAZCn5';

  // 必须与当前 AppId、HarmonyOS bundleName 和腾讯云控制台配置一致。
  static const _harmonyLicence =
      'oWxLt1xJmA3f1sRtPJwbYxc+i0601UsxhehpESH2oNSuDF40cJoVL+9UUfHwStdYs6QEDV1cYTSlM9QXA4QDWjpDdjS+cxEHEJJ7J3GibexaWjFR3LtJKn4mfgP1h90TDN5bdXmr6gWenicdVXByXEVqLgQhI8VvP098VNLcusZxmYuY2DKZDQ5fyjCt8MA/V+uFyTMAi2z651cNpRvzVik7PqgxN9EoxmECmz0EvrbDtWK6tG7FIsO1Yrq0bsUiw7ViurRuxSIDTJJbMKrJCy8zECYmVP0eLzMQJiZU/R4vMxAmJlT9Hiet4NEyLrDzNKJDDl67LbJbHlRU+vYuge8nI1MxC10Ki3ySnRsLaBjL8Ezr/xJ/mw==';

  Future<WysFaceVerifyResult> verify(WysFaceVerifyInput input) async {
    if (!input.isComplete) {
      return const WysFaceVerifyResult(
        success: false,
        code: 'INVALID_SERVER_DATA',
        description: '服务端返回的人脸核身参数不完整',
      );
    }

    try {
      final isProduction =
          AppEnvironment.instance.netEnvironment == WysNetEnvironment.product;
      final result = await _channel
          .invokeMapMethod<dynamic, dynamic>('startVerify', <String, dynamic>{
            'userid': input.userid,
            'orderNo': input.orderNo,
            'version': input.version,
            'sign': input.sign,
            'nonce': input.nonce,
            'faceId': input.faceId,
            'appId': isProduction ? _productionAppId : _testAppId,
            'licence': _harmonyLicence,
          });
      return WysFaceVerifyResult.fromJson(result);
    } on MissingPluginException {
      return const WysFaceVerifyResult(
        success: false,
        code: 'MISSING_PLUGIN',
        description: '当前设备未加载鸿蒙人脸核身插件',
      );
    } on PlatformException catch (error) {
      return WysFaceVerifyResult(
        success: false,
        code: error.code,
        description: error.message,
      );
    }
  }
}
