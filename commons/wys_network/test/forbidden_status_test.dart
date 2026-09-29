import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wys_network/wys_network.dart';

void main() {
  tearDown(() {
    onTokenExpired = null;
    onForbidden = null;
  });

  group('WysNetworkError.isForbidden', () {
    test('HTTP 403 → forbidden, not token expired', () {
      final err = WysNetworkError(
        message: '无权限',
        httpStatusCode: NetworkCodes.forbidden,
      );
      expect(NetworkCodes.forbidden, 403);
      expect(err.isForbidden, isTrue);
      expect(err.isTokenExpired, isFalse);
    });

    test('business code 403 → forbidden, not token expired', () {
      final err = WysNetworkError.business(
        code: NetworkCodes.forbidden,
        message: '无权限',
      );
      expect(err.isForbidden, isTrue);
      expect(err.isTokenExpired, isFalse);
    });
  });

  group('ResponseHandlerInterceptor 403', () {
    test('HTTP 403 calls onForbidden, not onTokenExpired', () {
      var forbiddenCalls = 0;
      var expiredCalls = 0;
      onForbidden = (_) => forbiddenCalls++;
      onTokenExpired = (_) => expiredCalls++;

      final interceptor = ResponseHandlerInterceptor();
      final response = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: NetworkCodes.forbidden,
        data: {'message': '无权限访问'},
      );

      interceptor.onResponse(
        response,
        ResponseInterceptorHandler(),
      );

      expect(forbiddenCalls, 1);
      expect(expiredCalls, 0);
    });

    test('business code 403 calls onForbidden, not onTokenExpired', () {
      var forbiddenCalls = 0;
      var expiredCalls = 0;
      onForbidden = (_) => forbiddenCalls++;
      onTokenExpired = (_) => expiredCalls++;

      final interceptor = ResponseHandlerInterceptor();
      final response = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: NetworkCodes.ok,
        data: {'code': NetworkCodes.forbidden, 'message': '无权限'},
      );

      interceptor.onResponse(
        response,
        ResponseInterceptorHandler(),
      );

      expect(forbiddenCalls, 1);
      expect(expiredCalls, 0);
    });
  });
}
