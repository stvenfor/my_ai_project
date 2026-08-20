import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../network_codes.dart';
import '../network_events.dart';
import '../wys_network_error.dart';

/// 对齐 iOS `dealWithresponseObject` + 旧 Flutter `HttpUtil` code 分支。
class ResponseHandlerInterceptor extends Interceptor {
  ResponseHandlerInterceptor({
    /// 旧 Flutter / iOS 在业务层判断 `code`，默认不 reject。
    this.throwOnBusinessError = false,
    this.autoToastOnFailure = false,
  });

  final bool throwOnBusinessError;
  final bool autoToastOnFailure;

  static const _silentMessages = {
    '内部服务器异常',
    '产品已被绑定',
    '该产品不属于TF产品',
    'error',
  };

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == NetworkCodes.expireToken) {
      final data = response.data;
      String message = '已退出登录，请重新登录';
      if (data is Map) {
        final m = data['message']?.toString();
        if (m != null && m.isNotEmpty) message = m;
      }
      final err = WysNetworkError.business(
        code: NetworkCodes.expireToken,
        message: message,
        responseBody: data,
      );
      if (!message.contains('用户不存在')) {
        onTokenExpired?.call(err);
      }
      return handler.next(response);
    }

    final data = response.data;
    if (data is! Map) {
      return handler.next(response);
    }

    final map = Map<String, dynamic>.from(data);
    final code = _intCode(map['code']);
    final message = map['message']?.toString() ?? '';

    if (code == NetworkCodes.passthrough) {
      return handler.next(response);
    }

    if (code == NetworkCodes.ok) {
      return handler.next(response);
    }

    if (code == NetworkCodes.invalidAuth && map['data'] == 1) {
      final err = WysNetworkError.business(
        code: code,
        message: message.isNotEmpty ? message : '未成年未认证',
        responseBody: map,
      );
      onInvalidAuth?.call(err);
      if (throwOnBusinessError) {
        return handler.reject(_businessException(response, err));
      }
      return handler.next(response);
    }

    if (code == NetworkCodes.expireToken) {
      final err = WysNetworkError.business(
        code: code,
        message: message.isNotEmpty ? message : '已退出登录，请重新登录',
        responseBody: map,
      );
      onTokenExpired?.call(err);
      if (throwOnBusinessError) {
        return handler.reject(_businessException(response, err));
      }
      return handler.next(response);
    }

    if (code == NetworkCodes.invalidAccount) {
      final err = WysNetworkError.business(
        code: code,
        message: message,
        responseBody: map,
      );
      onInvalidAccount?.call(err);
      if (throwOnBusinessError) {
        return handler.reject(_businessException(response, err));
      }
      return handler.next(response);
    }

    if (code == NetworkCodes.invalidMember) {
      final err = WysNetworkError.business(
        code: code,
        message: message,
        responseBody: map,
      );
      onInvalidMember?.call(err);
      if (throwOnBusinessError) {
        return handler.reject(_businessException(response, err));
      }
      return handler.next(response);
    }

    if (code == NetworkCodes.busy) {
      final err = WysNetworkError.business(
        code: code,
        message: message.isNotEmpty ? message : '网络拥堵，请稍后再试',
        responseBody: map,
      );
      onNetworkBusy?.call(err);
      if (throwOnBusinessError) {
        return handler.reject(_businessException(response, err));
      }
      return handler.next(response);
    }

    if (_isOAuthRefreshBody(map)) {
      return handler.next(response);
    }

    final err = WysNetworkError.business(
      code: code,
      message: message.isNotEmpty ? message : WysNetworkError.defaultMessage,
      responseBody: map,
    );
    onBusinessFailure?.call(err);
    if (autoToastOnFailure && !_silentMessages.contains(message)) {
      notifyToast(message);
    }
    if (throwOnBusinessError) {
      return handler.reject(_businessException(response, err));
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final tf = WysNetworkError.fromDio(err);

    if (status == NetworkCodes.expireToken &&
        !tf.message.contains('用户不存在')) {
      onTokenExpired?.call(tf);
    } else if (status == NetworkCodes.busy || tf.isBusy) {
      onNetworkBusy?.call(tf);
      if (autoToastOnFailure) {
        notifyToast('网络拥堵，请稍后再试');
      }
    } else if (autoToastOnFailure) {
      notifyToast(WysNetworkError.defaultMessage);
    }

    handler.next(err);
  }

  static bool _isOAuthRefreshBody(Map<String, dynamic> map) {
    return map.containsKey('refresh_token') &&
        map.containsKey('access_token') &&
        map.containsKey('expires_in');
  }

  static int _intCode(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? NetworkCodes.notNetwork;
    return NetworkCodes.notNetwork;
  }

  static DioException _businessException(Response response, WysNetworkError err) {
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: err,
      message: err.message,
    );
  }
}

/// 从 [Response] 解析业务体（HTTP 200 且未被拦截器 reject 时）。
ApiResponse<T> parseApiResponse<T>(
  Response<dynamic> response, {
  T Function(dynamic data)? dataParser,
}) {
  return ApiResponse.fromJson(response.data, dataParser: dataParser);
}