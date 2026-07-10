import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:module_auth/api/user_auth_api.dart';
import 'package:module_auth/session/device_auth_context.dart';
import 'package:module_auth/session/session_guard.dart';
import 'package:module_auth/session/session_recovery.dart';
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
        path.contains('/user/refresh')) {
      handler.next(err);
      return;
    }

    final message = SessionGuardHook.extractMessage(err.response?.data);
    if (SessionGuardHook.shouldForceLogout(message)) {
      final recovered = await SessionRecovery.tryRecover();
      if (recovered) {
        try {
          final response =
              await HttpManager.instance.dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {
          handler.next(err);
          return;
        }
      }
      handler.next(err);
      return;
    }
    if (!SessionGuardHook.shouldTryTokenRefresh(message)) {
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
      handler.next(err);
      return;
    }

    try {
      await _refreshTokens(refreshToken, userService, user);
      final response = await HttpManager.instance.dio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
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
