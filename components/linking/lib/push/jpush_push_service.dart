import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_linking/analytics/linking_analytics.dart';
import 'package:module_linking/deeplink/app_link_parser.dart';
import 'package:module_linking/models/push_payload.dart';
import 'package:module_linking/navigation/app_navigator.dart';
import 'package:module_linking/push/push_registration_api.dart';
import 'package:module_linking/push/push_service.dart';
import 'package:module_linking/ui/in_app_push_banner_controller.dart';
import 'package:module_utils/module_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wys_push/wys_push.dart';

/// 真实 JPush：委托 [PushManager]/[WysPushCoordinator]，上报 RegistrationID。
class JPushPushService implements PushService {
  JPushPushService({
    required LinkingAnalytics analytics,
    required PushRegistrationApi registrationApi,
    required AppLinkParser parser,
    required InAppPushBannerController bannerController,
    String? deviceId,
  })  : _analytics = analytics,
        _registrationApi = registrationApi,
        _parser = parser,
        _bannerController = bannerController,
        _deviceId = deviceId;

  final LinkingAnalytics _analytics;
  final PushRegistrationApi _registrationApi;
  final AppLinkParser _parser;
  final InAppPushBannerController _bannerController;
  final String? _deviceId;

  bool _initialized = false;
  String? _alias;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    PushManager.instance = JPushManager();
    PushManager.instance.reInit();

    // Android 13+：隐私同意后申请通知权限（经 module_utils → permission_handler）。
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await Permission.notification.request();
      } catch (e) {
        LogUtils.w('[JPush] notification permission request failed: $e');
      }
    }

    WysPushCoordinator.instance.init(
      onRoute: _onRoute,
      onNotificationArrived: (notification) {
        _analytics.trackPushArrive(
          msgId: notification?.id?.toString(),
          extras: notification?.extras ?? const {},
        );
        final title = notification?.title ?? '通知';
        final body = notification?.content ?? '';
        if (title.isEmpty && body.isEmpty) return;
        _bannerController.show(
          title: title,
          body: body,
          msgId: notification?.id?.toString(),
          onTap: () {
            final link = notification?.deeplink;
            if (link != null && link.isNotEmpty) {
              _onRoute(link);
            }
          },
        );
      },
      onNotificationOpened: (notification) {
        _analytics.trackPushClick(
          msgId: notification?.id?.toString(),
          deeplink: notification?.deeplink,
        );
      },
    );
    WysPushCoordinator.instance.markAppReady();
    unawaited(PushManager.instance.setBadgeNum(0));

    _initialized = true;
    LogUtils.i(
      '[JPush] service initialized configured=${PushConfig.isConfigured}',
    );

    final rid = await PushManager.instance.getRegistrationID();
    if (rid != null && rid.isNotEmpty) {
      await _registrationApi.report(
        registrationId: rid,
        alias: _alias,
        deviceId: _deviceId,
        mock: false,
      );
    }
  }

  void _onRoute(String uri) {
    final intent = _parser.parse(uri);
    if (intent == null) {
      LogUtils.w('[JPush] unresolved deeplink: $uri');
      return;
    }
    if (Get.isRegistered<AppNavigator>()) {
      unawaited(Get.find<AppNavigator>().navigate(intent));
    }
  }

  @override
  Future<String?> getRegistrationId() =>
      PushManager.instance.getRegistrationID();

  @override
  Future<void> setAlias(String alias) async {
    _alias = alias;
    _analytics.trackPushAliasSet(alias);
    final ok = await PushManager.instance.setAlias(alias);
    LogUtils.i('[JPush] setAlias alias=$alias ok=$ok');
    final rid = await PushManager.instance.getRegistrationID();
    if (rid != null && rid.isNotEmpty) {
      await _registrationApi.report(
        registrationId: rid,
        alias: alias,
        deviceId: _deviceId,
        mock: false,
      );
    }
  }

  @override
  Future<void> clearAlias() async {
    _alias = null;
    await PushManager.instance.deleteAlias();
    LogUtils.i('[JPush] clearAlias');
  }

  @override
  Future<void> simulatePush(
    PushPayload payload, {
    bool foreground = true,
  }) async {
    LogUtils.i(
      '[JPush] simulatePush ignored on real service title=${payload.title}',
    );
  }

  @override
  Future<void> dispose() async {
    WysPushCoordinator.instance.dispose();
    _initialized = false;
  }
}
