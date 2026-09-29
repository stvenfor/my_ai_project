import 'package:flutter_test/flutter_test.dart';
import 'package:module_core/core.dart';
import 'package:module_http/module_http.dart';
import 'package:module_realtime/client/realtime_auth_failure.dart';

void main() {
  group('classifyAuthHttp', () {
    test('10021/10022 → forceLogout', () {
      expect(
        classifyAuthHttp(code: AuthBizCode.sessionReplaced),
        AuthHttpDecision.forceLogout,
      );
      expect(
        classifyAuthHttp(code: AuthBizCode.sessionInvalid),
        AuthHttpDecision.forceLogout,
      );
    });

    test('HTTP 401 / tokenInvalid code → tryRefresh', () {
      expect(
        classifyAuthHttp(statusCode: 401, message: 'token 无效'),
        AuthHttpDecision.tryRefresh,
      );
      expect(
        classifyAuthHttp(code: AuthBizCode.tokenInvalid),
        AuthHttpDecision.tryRefresh,
      );
    });

    test('HTTP 403 → forbidden (不登出)', () {
      expect(
        classifyAuthHttp(statusCode: 403, message: '无权限'),
        AuthHttpDecision.forbidden,
      );
    });
  });

  group('isRealtimeAuthHardFailure', () {
    test('401 token 无效 is hard failure', () {
      expect(
        isRealtimeAuthHardFailure(
          HttpRequestException(message: 'token 无效', statusCode: 401),
        ),
        isTrue,
      );
    });

    test('403 is not hard failure', () {
      expect(
        isRealtimeAuthHardFailure(
          HttpRequestException(message: '无权限', statusCode: 403),
        ),
        isFalse,
      );
    });
  });
}
