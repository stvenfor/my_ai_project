import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_linking/analytics/linking_analytics.dart';
import 'package:module_linking/config/linking_config.dart';
import 'package:module_linking/deeplink/app_link_parser.dart';
import 'package:module_linking/models/push_payload.dart';
import 'package:module_linking/navigation/app_navigator.dart';
import 'package:module_linking/push/push_registration_api.dart';
import 'package:module_linking/push/push_service.dart';
import 'package:module_linking/ui/in_app_push_banner_controller.dart';
import 'package:module_utils/module_utils.dart';

/// Mock 极光推送（控制台应用创建前使用；结构对齐 JPush）。
class MockPushService implements PushService {
  MockPushService({
    required LinkingAnalytics analytics,
    required PushRegistrationApi registrationApi,
    required AppLinkParser parser,
    required InAppPushBannerController bannerController,
  })  : _analytics = analytics,
        _registrationApi = registrationApi,
        _parser = parser,
        _bannerController = bannerController;

  final LinkingAnalytics _analytics;
  final PushRegistrationApi _registrationApi;
  final AppLinkParser _parser;
  final InAppPushBannerController _bannerController;
  final _random = Random();

  bool _initialized = false;
  String? _registrationId;
  String? _alias;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    final env = Get.isRegistered<EnvironmentService>()
        ? Get.find<EnvironmentService>().currentEnv.value
        : AppEnv.test;
    final appKey = LinkingConfig.jpushAppKey(env);
    LogUtils.i(
      '[MockPush/JPush] initialize mock=${LinkingConfig.mockPush} appKey=$appKey',
    );
    _registrationId = 'mock_rid_${_random.nextInt(999999).toString().padLeft(6, '0')}';
    _initialized = true;
    await _registrationApi.report(
      registrationId: _registrationId!,
      alias: _alias,
      mock: true,
    );
  }

  @override
  Future<String?> getRegistrationId() async => _registrationId;

  @override
  Future<void> setAlias(String alias) async {
    _alias = alias;
    LogUtils.i('[MockPush/JPush] setAlias alias=$alias');
    _analytics.trackPushAliasSet(alias);
    if (_registrationId != null) {
      await _registrationApi.report(
        registrationId: _registrationId!,
        alias: alias,
        mock: true,
      );
    }
  }

  @override
  Future<void> clearAlias() async {
    _alias = null;
    LogUtils.i('[MockPush/JPush] clearAlias');
  }

  @override
  Future<void> simulatePush(PushPayload payload, {bool foreground = true}) async {
    _analytics.trackPushArrive(
      msgId: payload.msgId,
      extras: payload.extras,
    );

    if (foreground) {
      _analytics.trackPushBannerShow(msgId: payload.msgId);
      _bannerController.show(
        title: payload.title,
        body: payload.body,
        msgId: payload.msgId,
        onTap: () => _handlePushTap(payload, fromBanner: true),
      );
      return;
    }

    await _handlePushTap(payload, fromBanner: false);
  }

  Future<void> _handlePushTap(
    PushPayload payload, {
    required bool fromBanner,
  }) async {
    if (fromBanner) {
      _analytics.trackPushBannerClick(msgId: payload.msgId);
    }
    _analytics.trackPushClick(
      msgId: payload.msgId,
      deeplink: payload.deeplink,
    );
    final intent = payload.toRouteIntent((url) {
      final parsed = _parser.parse(url);
      if (parsed == null) {
        throw StateError('invalid deeplink: $url');
      }
      return parsed;
    });
    if (intent == null) {
      LogUtils.w('[MockPush] push without navigation target');
      return;
    }
    if (Get.isRegistered<AppNavigator>()) {
      await Get.find<AppNavigator>().navigate(intent);
    }
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}

/// 真实 JPush 接入占位（[LinkingConfig.mockPush]=false 时替换 [MockPushService]）。
class JPushPushService implements PushService {
  JPushPushService({
    required LinkingAnalytics analytics,
    required PushRegistrationApi registrationApi,
  })  : _analytics = analytics,
        _registrationApi = registrationApi;

  final LinkingAnalytics _analytics;
  final PushRegistrationApi _registrationApi;

  @override
  bool get isInitialized => false;

  @override
  Future<void> initialize() async {
    LogUtils.w(
      '[JPush] 真实 SDK 尚未接入，请在极光控制台创建应用后配置 AppKey / p8 / 厂商通道',
    );
    await _registrationApi.report(
      registrationId: 'jpush_not_configured',
      mock: false,
    );
  }

  @override
  Future<String?> getRegistrationId() async => null;

  @override
  Future<void> setAlias(String alias) async {
    _analytics.trackPushAliasSet(alias);
  }

  @override
  Future<void> clearAlias() async {}

  @override
  Future<void> simulatePush(PushPayload payload, {bool foreground = true}) async {}

  @override
  Future<void> dispose() async {}
}
