import 'package:get/get.dart';
import 'package:module_linking/analytics/linking_analytics.dart';
import 'package:module_linking/config/linking_config.dart';
import 'package:module_linking/deeplink/app_link_listener.dart';
import 'package:module_linking/deeplink/app_link_parser.dart';
import 'package:module_linking/linking_binding.dart';
import 'package:module_linking/navigation/app_navigator.dart';
import 'package:module_linking/navigation/pending_navigation.dart';
import 'package:module_linking/privacy/privacy_consent_service.dart';
import 'package:module_linking/push/mock_push_service.dart';
import 'package:module_linking/push/push_registration_api.dart';
import 'package:module_linking/push/push_service.dart';
import 'package:module_linking/ui/in_app_push_banner_controller.dart';
import 'package:module_route/route/login_redirect.dart';
import 'package:module_utils/module_utils.dart';

/// Deeplink + Push 统一初始化。
class LinkingInitializer {
  LinkingInitializer._();

  static AppLinkListener? _appLinkListener;
  static PushService? _pushService;

  static PushService? get pushService => _pushService;

  /// 启动阶段：注册 Binding；Deeplink 可配置关闭。
  static Future<void> initDeferred() async {
    LinkingBinding().dependencies();
    PrivacyConsentService.onGranted = _chainPrivacyGranted(
      PrivacyConsentService.onGranted,
    );

    LoginRedirect.onAfterAuthNavigation = _flushPendingAfterAuth;

    if (LinkingConfig.enableDeeplink) {
      final analytics = Get.find<LinkingAnalytics>();
      final parser = AppLinkParser();
      _appLinkListener = AppLinkListener(parser: parser, analytics: analytics);
      await _appLinkListener!.start();
    } else {
      LogUtils.i('[Linking] deeplink disabled, skip AppLinkListener');
    }

    if (PrivacyConsentService().isGranted) {
      await onPrivacyGranted();
    } else {
      LogUtils.i('[Linking] privacy not granted, skip JPush init');
    }
  }

  static Future<void> Function()? _chainPrivacyGranted(
    Future<void> Function()? previous,
  ) {
    return () async {
      await previous?.call();
      await onPrivacyGranted();
    };
  }

  /// 用户同意隐私协议后初始化推送。
  static Future<void> onPrivacyGranted() async {
    if (_pushService?.isInitialized == true) return;

    final analytics = Get.find<LinkingAnalytics>();
    final registrationApi = PushRegistrationApi(analytics: analytics);
    final parser = AppLinkParser();
    final bannerController = Get.find<InAppPushBannerController>();

    _pushService = LinkingConfig.mockPush
        ? MockPushService(
            analytics: analytics,
            registrationApi: registrationApi,
            parser: parser,
            bannerController: bannerController,
          )
        : JPushPushService(
            analytics: analytics,
            registrationApi: registrationApi,
          );

    await _pushService!.initialize();
    LogUtils.i('[Linking] push service initialized');
  }

  static Future<void> flushPendingNavigation() async {
    final pending = PendingNavigation.take();
    if (pending == null) return;
    if (!Get.isRegistered<AppNavigator>()) return;
    await Get.find<AppNavigator>().navigate(pending);
  }

  static Future<bool> _flushPendingAfterAuth() async {
    if (!PendingNavigation.hasPending) return false;
    await flushPendingNavigation();
    return true;
  }

  static Future<void> dispose() async {
    await _appLinkListener?.dispose();
    await _pushService?.dispose();
    _appLinkListener = null;
    _pushService = null;
  }
}
