import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:module_auth/api/user_auth_api.dart';
import 'package:module_auth/session/device_auth_context.dart';
import 'package:module_auth/session/session_guard.dart';
import 'package:module_core/core.dart';
import 'package:module_http/http/http.dart';
import 'package:module_utils/module_utils.dart';

/// access token 过期时静默 refresh 并重试原请求（单设备互踢仍走 [SessionGuardHook]）。
class AuthTokenRefreshInterceptor extends QueuedInterceptor {
  AuthTokenRefreshInterceptor({UserAuthApi? api}) : _api = api ?? UserAuthApi();

  static const skipAuthRefreshKey = 'skipAuthRefresh';

  final UserAuthApi _api;
  Completer<void>? _refreshCompleter;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.extra[skipAuthRefreshKey] == true) {
      handler.next(err);
      return;
    }
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final path = err.requestOptions.path;
    if (path.contains('/user/login') ||
        path.contains('/user/register') ||
        path.contains('/user/refresh') ||
        path.contains('/user/logout')) {
      handler.next(err);
      return;
    }

    final message = SessionGuardHook.extractMessage(err.response?.data);
    final code = SessionGuardHook.extractCode(err.response?.data);
    final statusCode = err.response?.statusCode;
    if (SessionGuardHook.shouldForceLogout(
      statusCode: statusCode,
      code: code,
      message: message,
    )) {
      // 互踢/会话无效：清会话回登录，勿把 401 原文抛给业务 toast。
      await SessionGuardHook.handleIfForceLogout(
        HttpRequestException(
          message: message.isEmpty ? '会话无效，请重新登录' : message,
          code: code?.toString(),
          statusCode: statusCode,
        ),
      );
      handler.reject(_sessionCleared(err));
      return;
    }
    if (!SessionGuardHook.shouldTryTokenRefresh(
      statusCode: statusCode,
      code: code,
      message: message,
    )) {
      handler.next(err);
      return;
    }

    if (!Get.isRegistered<UserService>()) {
      handler.next(err);
      return;
    }
    final userService = Get.find<UserService>();
    final user = userService.currentUser.value;
    final refreshToken = user?.refreshToken ?? '';
    if (refreshToken.isEmpty) {
      await SessionGuardHook.handleRefreshExhausted(
        code: code,
        message: message.isEmpty ? '登录已失效，请重新登录' : message,
      );
      handler.reject(_sessionCleared(err));
      return;
    }

    try {
      await _refreshTokens(refreshToken, userService, user);
      final response = await HttpManager.instance.dio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (_) {
      await SessionGuardHook.handleRefreshExhausted(
        code: code,
        message: message.isEmpty ? '登录已失效，请重新登录' : message,
      );
      handler.reject(_sessionCleared(err));
    }
  }

  DioException _sessionCleared(DioException err) {
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: DioExceptionType.cancel,
      error: const SessionClearedFailure(),
      message: '登录已失效，请重新登录',
    );
  }

  Future<void> _refreshTokens(
    String refreshToken,
    UserService userService,
    User? user,
  ) async {
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return;
    }
    _refreshCompleter = Completer<void>();
    try {
      final device = await DeviceAuthContext.resolve();
      final deviceId = user?.deviceId.isNotEmpty == true &&
              !DeviceInfoUtils.isPlaceholderDeviceId(user!.deviceId)
          ? user.deviceId
          : device.deviceId;
      final result = await _api.refresh(
        refreshToken: refreshToken,
        deviceId: deviceId,
        sessionId: user?.sessionId,
        platform: device.platform,
      );
      await userService.updateAuthTokens(
        token: result.token,
        refreshToken: result.refreshToken,
        sessionId: result.sessionId,
      );
      if (user != null && user.deviceId != deviceId) {
        final current = userService.currentUser.value;
        if (current != null) {
          await userService.setUser(current.copyWith(deviceId: deviceId));
        }
      }
      _refreshCompleter!.complete();
    } catch (error, stackTrace) {
      _refreshCompleter!.completeError(error, stackTrace);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}
